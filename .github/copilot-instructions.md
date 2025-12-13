# Prostore - AI Agent Instructions

## Architecture Overview

**Tech Stack**: Next.js 16 (App Router) + React 19 + TypeScript + Prisma 6.5 + PostgreSQL + NextAuth v5

**Key Pattern**: Server Actions architecture - all data mutations happen in `lib/actions/*.actions.ts` files marked with `'use server'` directive. These are called directly from Client/Server Components.

### Directory Structure

```
app/
  (auth)/          # Sign-in/sign-up flows (route group)
  (root)/          # Public shopping pages (route group)
  admin/           # Admin dashboard (protected)
  user/            # User profile & orders (protected)
  api/auth/        # NextAuth handlers only
lib/
  actions/         # Server Actions - all DB operations
  validators.ts    # Zod schemas for validation
  constants/       # App-wide constants & defaults
db/
  prisma.ts        # Prisma client setup with singleton pattern
  seed.ts          # Sample data seeder
```

## Critical Patterns

### 1. Prisma Client Architecture (IMPORTANT)

**Two separate Prisma exports** in `db/prisma.ts` with singleton pattern:

- `prisma` - Base client for auth and user operations (no extensions)
- `prismaExtended` - Extended client with `$extends()` for Product/Cart/Order (converts Decimal → string)

**When to use which**:
- Use `prisma` in `auth.ts` and `user.actions.ts` (auth needs base client)
- Use `prismaExtended` in `product.actions.ts`, `cart.actions.ts`, `order.actions.ts`, `review.actions.ts`

**Why**: Prisma Client Extensions (`$extends`) are NOT serializable for RSC. Auth operations must use the base client to avoid RSC serialization errors.

**CRITICAL**: In `prismaExtended` compute functions, parameter names MUST match the model type:
```typescript
// ✅ CORRECT
orderItem: {
  price: {
    compute(orderItem) {  // Parameter name matches model
      return orderItem.price.toString();
    },
  },
}

// ❌ WRONG - Will not transform price
orderItem: {
  price: {
    compute(cart) {  // Wrong parameter name
      return cart.price.toString();
    },
  },
}
```

```typescript
// ✅ CORRECT - auth.ts
import { prisma } from '@/db/prisma';

// ✅ CORRECT - product.actions.ts
import { prismaExtended as prisma } from '@/db/prisma';
```

### 2. Server Actions Pattern

All DB operations follow this pattern:

```typescript
'use server';
import { prismaExtended as prisma } from '@/db/prisma';
import { convertToPlainObject, formatError } from '../utils';

export async function getProductBySlug(slug: string) {
  const data = await prisma.product.findFirst({ where: { slug } });
  return convertToPlainObject(data); // REQUIRED for RSC
}
```

**Always**:
- Wrap Prisma results with `convertToPlainObject()` before returning (strips Prisma metadata for RSC)
- Use `formatError()` for consistent error handling (handles Zod, Prisma, and generic errors)
- Validate inputs with Zod schemas from `lib/validators.ts`
- Call `revalidatePath()` after mutations to update cached pages

### 3. NextAuth v5 Configuration

Split config pattern for edge compatibility:

- `auth.config.ts` - Edge-safe config (used in middleware)
- `auth.ts` - Full config with Prisma adapter (NOT for edge)

**Middleware** (`middleware.ts`) runs on edge and only imports `auth.config.ts`. Full auth with DB access happens elsewhere.

Protected routes defined in `authConfig.callbacks.authorized()` using regex patterns.

### 4. Type Safety

Types derived from Zod schemas, not Prisma:

```typescript
// types/index.ts
import { z } from 'zod';
import { insertProductSchema } from '@/lib/validators';

export type Product = z.infer<typeof insertProductSchema> & {
  id: string;
  rating: string; // Note: string, not Decimal (from prismaExtended)
  createdAt: Date;
};
```

## Development Workflow

### Essential Commands

```bash
# Development
npm run dev                 # Start dev server (uses --webpack flag)

# Database
npx prisma generate         # Regenerate Prisma Client (after schema changes)
npx prisma studio           # Open Prisma Studio GUI
npx tsx ./db/seed           # Seed database with sample data
npx prisma migrate dev      # Create and apply migration
npx prisma db pull          # Pull schema from existing database

# Testing
npm test                    # Run Jest tests
npm run test:watch          # Watch mode
```

### Environment Variables Setup

**CRITICAL**: `.env` file requires NO SPACES around `=` signs:
```bash
# ❌ WRONG
NEXT_PUBLIC_APP_NAME = "Prostore"

# ✅ CORRECT
NEXT_PUBLIC_APP_NAME="Prostore"
```

### Troubleshooting RSC/Prisma Errors

**Error: `{clientVersion: "6.5.0"}`**
- Check that action files use `prismaExtended as prisma` (not base `prisma`)
- Run `npx prisma generate` to regenerate client
- Delete `.next` folder to clear build cache
- Restart dev server

**Error: Environment variables undefined**
- Verify `.env` has NO SPACES around `=`
- Check `NODE_ENV` is correct (dev vs production)
- Restart dev server after `.env` changes

## Key Conventions

### File Naming
- Server Actions: `*.actions.ts` with `'use server'`
- Route folders: `(group-name)` for layout grouping without URL segments
- Dynamic routes: `[id]/page.tsx` or `[slug]/page.tsx`

### Authorization & Protection

**Admin Routes** - All admin pages call `requireAdmin()` guard:
```typescript
// app/admin/products/page.tsx
import { requireAdmin } from '@/lib/auth-guard';

export default async function AdminProductsPage() {
  await requireAdmin();  // Redirects to /unauthorized if not admin
  // ... rest of page
}
```

**Order Owner Verification** - Check user ownership before displaying:
```typescript
// app/(root)/order/[id]/page.tsx
if (order.userId !== session?.user.id && session?.user.role !== 'admin') {
  return redirect('/unauthorized');
}
```

**Role-based UI** - Show admin link conditionally:
```typescript
{session?.user?.role === 'admin' && (
  <Link href='/admin/overview'>Admin Dashboard</Link>
)}
```

### Data Flow
1. Component calls Server Action from `lib/actions/`
2. Server Action validates with Zod schema from `lib/validators.ts`
3. Server Action performs Prisma operation (using correct client)
4. Result wrapped in `convertToPlainObject()` before return
5. Error handling via `formatError()` utility

### Cart & Sessions
- Anonymous users get `sessionCartId` cookie (auto-generated in middleware)
- On sign-in, cart ownership transfers from `sessionCartId` to `userId` (see `auth.ts` jwt callback)
- Cart calculation logic centralized in `cart.actions.ts` `calcPrice()` function

### Decimal Handling
- Database stores as `Decimal` (12,2 precision)
- `prismaExtended` converts to `string` via computed fields
- Use `round2()` utility for calculations, `formatCurrency()` for display
- **Parameter name in compute function MUST match model name** for transformation to work

### UI Component Patterns
- Use `DeleteDialog` component for destructive actions (wraps confirmation dialog)
- Use `Pagination` for paginated lists (handles page numbers)
- Use `AdminSearch` form for admin table filtering (GET form, not Server Action)
- Form components use React Hook Form + Zod validation via `react-hook-form` 
- Use `formatId()` to shorten UUIDs in tables (`..abc123`)

### File Upload
- Uploadthing authenticated via `middleware()` in `app/api/uploadthing/core.ts`
- Requires session check before allowing upload
- Max file size 4MB for images
- Returns uploaded file URL for storing in DB

### Pagination Pattern
Admin tables pass `page` and `query` as search params:
```typescript
// Server Action returns paginated results
const users = await getAllUsers({ page: Number(page), query: searchText });
// Use Pagination component: <Pagination page={page} totalPages={users.totalPages} />
```

### Payment Integration Patterns

**Checkout Flow**: 4-step process with `CheckoutSteps` component:
1. User Login → 2. Shipping Address → 3. Payment Method → 4. Place Order

**Payment Methods**: Configurable via `PAYMENT_METHODS` env var:
- PayPal (client-side buttons)
- Stripe (client-side form)
- CashOnDelivery (admin marks as paid)

**PayPal Integration**:
```typescript
// Server-side: Create order
const paypalOrder = await paypal.createOrder(Number(order.totalPrice));
// Client-side: PayPal buttons handle approval
<PayPalButtons createOrder={handleCreatePayPalOrder} onApprove={handleApprovePayPalOrder} />
```

**Stripe Integration**:
```typescript
// Server-side: Create payment intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: Math.round(Number(order.totalPrice) * 100),
  currency: 'USD',
  metadata: { orderId: order.id },
});
// Client-side: Stripe Elements form
<Elements options={{ clientSecret }} stripe={stripePromise}>
  <PaymentElement />
</Elements>
```

**Order Status Updates**: After payment success:
```typescript
await updateOrderToPaid({
  orderId,
  paymentResult: { id, status, email_address, pricePaid }
});
revalidatePath(`/order/${orderId}`);
```

### Email Integration

**Purchase Receipts**: Automatic email after order completion:
```typescript
import { sendPurchaseReceipt } from '@/email';
await sendPurchaseReceipt({ order });
```

**Email Templates**: React Email components in `email/` directory:
- `purchase-receipt.tsx` - Order confirmation with details
- Uses Resend API for delivery

### Testing Patterns

**PayPal Tests**: Sandbox credentials in `tests/paypal.test.ts`:
```typescript
test('creates a paypal order', async () => {
  const orderResponse = await paypal.createOrder(price);
  expect(orderResponse.status).toBe('CREATED');
});
```

**Jest Setup**: `jest.setup.ts` loads dotenv for env vars in tests.

## Environment Variables

Required variables in `.env` (NO SPACES around `=`):

```bash
# App
NEXT_PUBLIC_APP_NAME="Prostore"
NEXT_PUBLIC_APP_DESCRIPTION="A modern ecommerce store built with Next.js"
NEXT_PUBLIC_SERVER_URL="http://localhost:3000"

# Database (standard PostgreSQL URL)
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# Auth
NEXTAUTH_SECRET="$(openssl rand -base64 32)"
NEXTAUTH_URL="http://localhost:3000"

# Payments
PAYPAL_API_URL="https://api-m.sandbox.paypal.com"
PAYPAL_CLIENT_ID=""
PAYPAL_APP_SECRET=""

# File Upload
UPLOADTHING_TOKEN=""
UPLOADTHING_SECRET=""
UPLOADTHING_APPID=""

# Payment (Stripe)
STRIPE_SECRET_KEY=""
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=""

# Email
RESEND_API_KEY=""
SENDER_EMAIL="onboarding@resend.dev"
```

## Database Setup

**For Local Docker PostgreSQL**:
```bash
DATABASE_URL="postgresql://postgres:secret@localhost:5432/neondb?schema=public"
```

**Setup**: Remove `previewFeatures` from `prisma/schema.prisma` and use native PostgreSQL driver (no adapter needed).

### Middleware Cookie Management

**Critical**: `auth.config.ts` middleware auto-generates `sessionCartId` cookie for all requests:

```typescript
// auth.config.ts - authorized() callback
if (!request.cookies.get('sessionCartId')) {
  const sessionCartId = crypto.randomUUID();
  response.cookies.set('sessionCartId', sessionCartId);
  return response;
}
```

This enables anonymous cart tracking. On sign-in, ownership transfers from `sessionCartId` to `userId` via `auth.ts` jwt callback.

## Known Issues & Solutions

### Issue: `{clientVersion: "6.5.0"}` RSC Error
**Solution**: 
- Verify action files use `prismaExtended as prisma` (not base `prisma`)
- Run `npx prisma generate` to regenerate client
- Delete `.next` folder and restart dev server

### Issue: Decimal fields not converting to strings
**Solution**: Check `prismaExtended` compute function parameter names match model names exactly (e.g., `orderItem`, not `cart`)

### Issue: Cart inheritance between users
**Solution**: `user.actions.ts` `signOutUser()` deletes cart on logout to prevent session bleed

### Issue: Environment variables undefined
**Solution**: Ensure `.env` has NO SPACES around `=` signs, restart dev server

### Issue: Tailwind v3 vs v4
**Current version**: v3. If upgrading to v4, run `npx @tailwindcss/upgrade` and update imports

## Deployment Notes

- **Local Dev**: Docker PostgreSQL + native driver
- **Production**: Vercel with Postgres (Neon/Supabase/etc.)
- `postinstall` script auto-runs `prisma generate` on deploy
- Always apply migrations before deployment: `npx prisma migrate deploy`
- Verify `DATABASE_URL` has proper connection pooling in production
