--
-- PostgreSQL database dump
--

\restrict v4AJb9uORjTOYEVfbECFv8DcI5cPU71zVPxytoZ4mdZKVpSPXrQUBwbAQk1HsO9

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3 (Debian 18.3-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Account" (
    "userId" uuid NOT NULL,
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Account" OWNER TO postgres;

--
-- Name: Cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cart" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "userId" uuid,
    "sessionCartId" text NOT NULL,
    items json[] DEFAULT ARRAY[]::json[],
    "itemsPrice" numeric(12,2) NOT NULL,
    "totalPrice" numeric(12,2) NOT NULL,
    "shippingPrice" numeric(12,2) NOT NULL,
    "taxPrice" numeric(12,2) NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Cart" OWNER TO postgres;

--
-- Name: Order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Order" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "userId" uuid NOT NULL,
    "shippingAddress" json NOT NULL,
    "paymentMethod" text NOT NULL,
    "paymentResult" json,
    "itemsPrice" numeric(12,2) NOT NULL,
    "shippingPrice" numeric(12,2) NOT NULL,
    "taxPrice" numeric(12,2) NOT NULL,
    "totalPrice" numeric(12,2) NOT NULL,
    "isPaid" boolean DEFAULT false NOT NULL,
    "paidAt" timestamp(6) without time zone,
    "isDelivered" boolean DEFAULT false NOT NULL,
    "deliveredAt" timestamp(6) without time zone,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Order" OWNER TO postgres;

--
-- Name: OrderItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderItem" (
    "orderId" uuid NOT NULL,
    "productId" uuid NOT NULL,
    qty integer NOT NULL,
    price numeric(12,2) NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    image text NOT NULL
);


ALTER TABLE public."OrderItem" OWNER TO postgres;

--
-- Name: Product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Product" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    category text NOT NULL,
    images text[],
    brand text NOT NULL,
    description text NOT NULL,
    stock integer NOT NULL,
    price numeric(12,2) DEFAULT 0 NOT NULL,
    rating numeric(3,2) DEFAULT 0 NOT NULL,
    "numReviews" integer DEFAULT 0 NOT NULL,
    "isFeatured" boolean DEFAULT false NOT NULL,
    banner text,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Product" OWNER TO postgres;

--
-- Name: Review; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Review" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "userId" uuid NOT NULL,
    "productId" uuid NOT NULL,
    rating integer NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    "isVerifiedPurchase" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Review" OWNER TO postgres;

--
-- Name: Session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Session" (
    "sessionToken" text NOT NULL,
    "userId" uuid NOT NULL,
    expires timestamp(6) without time zone NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Session" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text DEFAULT 'NO_NAME'::text NOT NULL,
    email text NOT NULL,
    "emailVerified" timestamp(6) without time zone,
    image text,
    password text,
    role text DEFAULT 'user'::text NOT NULL,
    address json,
    "paymentMethod" text,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: VerificationToken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."VerificationToken" (
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."VerificationToken" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Data for Name: Account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Account" ("userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, token_type, scope, id_token, session_state, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Cart" (id, "userId", "sessionCartId", items, "itemsPrice", "totalPrice", "shippingPrice", "taxPrice", "createdAt") FROM stdin;
a428800e-e580-410b-bf91-6c2c526b1707	\N	f5ffd501-b0f8-4edf-b144-67d881c63571	{"{\\"productId\\":\\"cb630085-965a-47b5-8c34-6c954d9cff12\\",\\"name\\":\\"Brooks Brothers Long Sleeved Shirt\\",\\"slug\\":\\"brooks-brothers-long-sleeved-shirt\\",\\"qty\\":1,\\"image\\":\\"/images/sample-products/p2-1.jpg\\",\\"price\\":\\"85.9\\"}"}	85.90	108.79	10.00	12.89	2026-03-01 22:49:00.789
7089ddb1-d63d-43af-b0df-b7b9317afca1	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	868c6303-ef31-4c9d-be86-1af96c1d832f	{}	0.00	0.00	0.00	0.00	2026-03-02 03:07:28.915
\.


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Order" (id, "userId", "shippingAddress", "paymentMethod", "paymentResult", "itemsPrice", "shippingPrice", "taxPrice", "totalPrice", "isPaid", "paidAt", "isDelivered", "deliveredAt", "createdAt") FROM stdin;
8571fa90-9a1e-4a7b-ab44-5b47700d7965	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	139.94	0.00	20.99	160.93	f	\N	f	\N	2026-02-26 03:08:46.15
e296a2b0-bb02-473a-801f-e588e7860f6b	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	799.92	0.00	119.99	919.91	f	\N	f	\N	2026-02-26 03:15:23.85
abc22dc3-89d9-4a2c-962c-89301bb9bec1	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	59.99	10.00	9.00	78.99	f	\N	f	\N	2026-03-01 22:51:40.776
5ef93cef-5206-4fcc-8984-7743d43de85e	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	39.95	10.00	5.99	55.94	f	\N	f	\N	2026-03-01 22:52:57.655
bab7b84f-4476-40db-8e84-65080f51b44c	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	39.95	10.00	5.99	55.94	f	\N	f	\N	2026-03-02 03:07:36.726
22c1c5ae-438d-4441-a98d-8d2ed7e33f08	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	\N	239.97	0.00	36.00	275.97	f	\N	f	\N	2026-03-02 09:53:34.409
\.


--
-- Data for Name: OrderItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderItem" ("orderId", "productId", qty, price, name, slug, image) FROM stdin;
8571fa90-9a1e-4a7b-ab44-5b47700d7965	debfef7c-b2eb-44e0-b60c-64db1d58be6e	1	39.95	Calvin Klein Slim Fit Stretch Shirt	calvin-klein-slim-fit-stretch-shirt	/images/sample-products/p4-1.jpg
8571fa90-9a1e-4a7b-ab44-5b47700d7965	c7ba1e6a-8743-4824-aa91-5494398a95ec	1	99.99	Polo Classic Pink Hoodie	polo-classic-pink-hoodie	/images/sample-products/p6-1.jpg
e296a2b0-bb02-473a-801f-e588e7860f6b	c7ba1e6a-8743-4824-aa91-5494398a95ec	8	99.99	Polo Classic Pink Hoodie	polo-classic-pink-hoodie	/images/sample-products/p6-1.jpg
abc22dc3-89d9-4a2c-962c-89301bb9bec1	f4204841-e158-4a9c-8248-f9189a1db798	1	59.99	Polo Sporting Stretch Shirt	polo-sporting-stretch-shirt	/images/sample-products/p1-1.jpg
5ef93cef-5206-4fcc-8984-7743d43de85e	debfef7c-b2eb-44e0-b60c-64db1d58be6e	1	39.95	Calvin Klein Slim Fit Stretch Shirt	calvin-klein-slim-fit-stretch-shirt	/images/sample-products/p4-1.jpg
bab7b84f-4476-40db-8e84-65080f51b44c	debfef7c-b2eb-44e0-b60c-64db1d58be6e	1	39.95	Calvin Klein Slim Fit Stretch Shirt	calvin-klein-slim-fit-stretch-shirt	/images/sample-products/p4-1.jpg
22c1c5ae-438d-4441-a98d-8d2ed7e33f08	b6450380-5459-4caf-8047-9f82f85dd5f7	3	79.99	Polo Ralph Lauren Oxford Shirt	polo-ralph-lauren-oxford-shirt	/images/sample-products/p5-1.jpg
\.


--
-- Data for Name: Product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Product" (id, name, slug, category, images, brand, description, stock, price, rating, "numReviews", "isFeatured", banner, "createdAt") FROM stdin;
f4204841-e158-4a9c-8248-f9189a1db798	Polo Sporting Stretch Shirt	polo-sporting-stretch-shirt	Men's Dress Shirts	{/images/sample-products/p1-1.jpg,/images/sample-products/p1-2.jpg}	Polo	Classic Polo style with modern comfort	5	59.99	4.50	10	t	/images/banner-1.jpg	2026-02-08 21:45:38.122
7d228874-0cc7-4a25-bbd6-9e967aec4987	Tommy Hilfiger Classic Fit Dress Shirt	tommy-hilfiger-classic-fit-dress-shirt	Men's Dress Shirts	{/images/sample-products/p3-1.jpg,/images/sample-products/p3-2.jpg}	Tommy Hilfiger	A perfect blend of sophistication and comfort	0	99.95	4.90	3	f	\N	2026-02-08 21:45:38.122
debfef7c-b2eb-44e0-b60c-64db1d58be6e	Calvin Klein Slim Fit Stretch Shirt	calvin-klein-slim-fit-stretch-shirt	Men's Dress Shirts	{/images/sample-products/p4-1.jpg,/images/sample-products/p4-2.jpg}	Calvin Klein	Streamlined design with flexible stretch fabric	10	39.95	3.60	5	f	\N	2026-02-08 21:45:38.122
b6450380-5459-4caf-8047-9f82f85dd5f7	Polo Ralph Lauren Oxford Shirt	polo-ralph-lauren-oxford-shirt	Men's Dress Shirts	{/images/sample-products/p5-1.jpg,/images/sample-products/p5-2.jpg}	Polo	Iconic Polo design with refined oxford fabric	6	79.99	4.70	18	f	\N	2026-02-08 21:45:38.122
c7ba1e6a-8743-4824-aa91-5494398a95ec	Polo Classic Pink Hoodie	polo-classic-pink-hoodie	Men's Sweatshirts	{/images/sample-products/p6-1.jpg,/images/sample-products/p6-2.jpg}	Polo	Soft, stylish, and perfect for laid-back days	8	99.99	4.60	12	f	\N	2026-02-08 21:45:38.122
cb630085-965a-47b5-8c34-6c954d9cff12	Brooks Brothers Long Sleeved Shirt	brooks-brothers-long-sleeved-shirt	Men's Dress Shirts	{/images/sample-products/p2-1.jpg,/images/sample-products/p2-2.jpg}	Brooks Brothers	Timeless style and premium comfort	10	85.90	5.00	1	t	/images/banner-2.jpg	2026-02-08 21:45:38.122
\.


--
-- Data for Name: Review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Review" (id, "userId", "productId", rating, title, description, "isVerifiedPurchase", "createdAt") FROM stdin;
43a508c4-e789-4f58-ab37-51dcfae593cb	157c6aed-fba4-4113-8c14-3fa7d75c0b0a	cb630085-965a-47b5-8c34-6c954d9cff12	5	test review	good shirt	t	2026-03-01 23:50:13.276
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Session" ("sessionToken", "userId", expires, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, name, email, "emailVerified", image, password, role, address, "paymentMethod", "createdAt", "updatedAt") FROM stdin;
d0c5f94a-1a93-49f9-84b5-df1a48941046	Jaya Sharma	jaya.umd@gmail.com	\N	\N	97fe8aeeec517f3c5cbbdfb59f7858f5214ce3801ffc62e64b622c5842446626	admin	\N	\N	2026-03-02 02:48:40.921	2026-03-02 02:50:38.673
b6db6f84-812a-46cb-83f1-b6f3ac4f73e4	Ajun Sharma	info@jdlab.us	\N	\N	97fe8aeeec517f3c5cbbdfb59f7858f5214ce3801ffc62e64b622c5842446626	admin	\N	\N	2026-02-26 03:38:39.117	2026-03-02 02:50:44.376
157c6aed-fba4-4113-8c14-3fa7d75c0b0a	Mugundhan Elamathi	emugundhan@gmail.com	\N	\N	f467bf44206e2b744d912fb8045bc517749a899f989b39622cdb9488b96b5144	admin	{"fullName":"Mugundhan Elamathi","streetAddress":"2001 Grand Ave, Apt 3D","city":"North Bergen","postalCode":"07047","country":"United States"}	PayPal	2026-02-26 03:05:30.038	2026-03-02 09:53:33.084
\.


--
-- Data for Name: VerificationToken; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."VerificationToken" (identifier, token, expires) FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
c259e31f-43b3-469f-88b6-ec8f18ea952a	4793481c14a80cd47a4dcdf89d4a2e749aea0d0121deed2bafc7f3fdb5caf622	2026-02-08 21:38:03.165219+00	20241116125832_init	\N	\N	2026-02-08 21:38:03.143598+00	1
c52e15ef-d7ff-4d76-b110-23859907a551	bc0c483016f896bdfd4ee75bf3296904c2454b1d2f10c22a42736cd0fb3b076e	2026-02-08 21:38:03.193074+00	20241118183645_add_user_based_tables	\N	\N	2026-02-08 21:38:03.170315+00	1
62235fc1-a9ab-4d82-ae11-113845b9bc1b	c282454291dc2d7641607ca3470fc159e6f3e8dfbd570c3eeeccebb1c3cb609d	2026-02-08 21:38:03.215787+00	20241121210251_add_cart	\N	\N	2026-02-08 21:38:03.197493+00	1
73e9d06b-cb88-49a3-970d-2ba8093b4a30	a3207efb6d5a04872e62eb17c3f169609b0dc9734667c5c5d7b590c2ffbbce4c	2026-02-08 21:38:03.241191+00	20241125173259_add_order	\N	\N	2026-02-08 21:38:03.221514+00	1
8e081687-93e7-4bd8-9b53-c2a37a75bcc9	cc85125acc17751d2f8edac626f35272caf696b8c5dcaf9b3a43aa4fd7bd4d77	2026-02-08 21:38:03.262115+00	20241205162619_add_featured_default	\N	\N	2026-02-08 21:38:03.24654+00	1
71f1b1ed-5fde-49d0-9dc4-bc2baa8035f9	24906af435f87afad6c35311e1a7242041f1864943fb894bbe2161672268d056	2026-02-08 21:38:03.283088+00	20241209181915_add_review	\N	\N	2026-02-08 21:38:03.266153+00	1
\.


--
-- Name: Account Account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_pkey" PRIMARY KEY (provider, "providerAccountId");


--
-- Name: Cart Cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "Cart_pkey" PRIMARY KEY (id);


--
-- Name: Order Order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (id);


--
-- Name: Product Product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);


--
-- Name: Review Review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY ("sessionToken");


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VerificationToken VerificationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_pkey" PRIMARY KEY (identifier, token);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: OrderItem orderitems_orderId_productId_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "orderitems_orderId_productId_pk" PRIMARY KEY ("orderId", "productId");


--
-- Name: product_slug_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX product_slug_idx ON public."Product" USING btree (slug);


--
-- Name: user_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_email_idx ON public."User" USING btree (email);


--
-- Name: Account Account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Cart Cart_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "Cart_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderItem OrderItem_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderItem OrderItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order Order_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review Review_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review Review_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict v4AJb9uORjTOYEVfbECFv8DcI5cPU71zVPxytoZ4mdZKVpSPXrQUBwbAQk1HsO9

