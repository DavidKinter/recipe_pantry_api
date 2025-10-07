--
-- PostgreSQL database dump
--

\restrict 5MFdTWmFD59flMbLvdif1fZbL4BWZnqkgnDGuUbixl00QK3bqIzpbrVffCZvtSP

-- Dumped from database version 17.6 (Homebrew)
-- Dumped by pg_dump version 17.6 (Homebrew)

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
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: David
--

CREATE SEQUENCE public.recipes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipes_id_seq OWNER TO "David";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: recipes; Type: TABLE; Schema: public; Owner: David
--

CREATE TABLE public.recipes (
    id integer DEFAULT nextval('public.recipes_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    ingredients_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    instructions text NOT NULL,
    prep_minutes integer,
    is_public boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.recipes OWNER TO "David";

--
-- Name: user_pantry_id_seq; Type: SEQUENCE; Schema: public; Owner: David
--

CREATE SEQUENCE public.user_pantry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_pantry_id_seq OWNER TO "David";

--
-- Name: user_pantry; Type: TABLE; Schema: public; Owner: David
--

CREATE TABLE public.user_pantry (
    id integer DEFAULT nextval('public.user_pantry_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    ingredients_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_pantry OWNER TO "David";

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: David
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO "David";

--
-- Name: users; Type: TABLE; Schema: public; Owner: David
--

CREATE TABLE public.users (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    role character varying(20) DEFAULT 'user'::character varying NOT NULL,
    password_hash character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT check_role_values CHECK (((role)::text = ANY (ARRAY[('admin'::character varying)::text, ('user'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO "David";

--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: David
--

COPY public.recipes (id, user_id, title, ingredients_json, instructions, prep_minutes, is_public, created_at, updated_at) FROM stdin;
1	2	Moussaka	["eggplant", "ground beef", "onion", "garlic", "tomato paste", "red wine", "cinnamon", "nutmeg", "butter", "flour", "milk", "eggs", "parmesan cheese", "olive oil", "salt", "pepper"]	Slice and salt eggplant, let drain 30 min. Brown meat with onions and garlic. Add tomato paste, wine, spices. Make béchamel sauce. Layer eggplant, meat, béchamel. Bake at 180°C for 45 minutes	45	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
2	2	Souvlaki	["pork shoulder", "lemon juice", "olive oil", "oregano", "garlic", "salt", "pepper", "pita bread", "tzatziki", "tomatoes", "onions"]	Cut meat into cubes. Marinate with lemon, oil, oregano for 2 hours. Thread onto skewers. Grill 10-12 minutes, turning frequently. Serve in pita with tzatziki	140	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
3	2	Greek Salad (Horiatiki)	["tomatoes", "cucumber", "red onion", "green pepper", "kalamata olives", "feta cheese", "olive oil", "oregano", "salt"]	Cut tomatoes into wedges. Slice cucumber and onion. Cut pepper into rings. Combine vegetables with olives. Top with feta block. Drizzle olive oil and oregano	10	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
4	2	Spanakopita	["spinach", "feta cheese", "ricotta cheese", "eggs", "onion", "dill", "parsley", "phyllo dough", "butter", "olive oil", "salt", "pepper"]	Sauté onions and spinach. Mix with cheeses, eggs, herbs. Layer phyllo sheets with butter. Add filling and wrap. Bake at 180°C until golden	30	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
5	2	Dolmades	["grape leaves", "rice", "onion", "pine nuts", "currants", "dill", "mint", "parsley", "lemon juice", "olive oil", "salt", "pepper"]	Blanch grape leaves. Sauté onions, add rice and herbs. Cool filling. Wrap leaves around filling. Steam with lemon water for 40 minutes	45	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
6	2	Pastitsio	["pasta", "ground beef", "onion", "garlic", "tomato sauce", "cinnamon", "nutmeg", "butter", "flour", "milk", "eggs", "parmesan cheese", "olive oil"]	Cook pasta al dente. Make meat sauce with spices. Prepare béchamel. Layer pasta, meat, béchamel. Bake until golden brown	30	f	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
7	2	Tzatziki	["greek yogurt", "cucumber", "garlic", "dill", "lemon juice", "olive oil", "salt"]	Grate and drain cucumber. Mix yogurt with minced garlic. Add cucumber and dill. Season with lemon and salt. Chill before serving	15	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
8	2	Fasolada	["white beans", "onion", "carrots", "celery", "tomato paste", "olive oil", "bay leaves", "salt", "pepper"]	Soak beans overnight. Sauté vegetables in olive oil. Add beans and water. Simmer for 90 minutes. Season and serve with bread	20	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
9	2	Baklava	["phyllo dough", "walnuts", "almonds", "cinnamon", "cloves", "butter", "sugar", "honey", "water", "lemon juice"]	Mix chopped nuts with spices. Layer phyllo with butter. Add nut mixture. Cut into diamonds. Bake and pour syrup while hot	45	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
10	2	Avgolemono Soup	["chicken", "rice", "eggs", "lemon juice", "onion", "carrots", "celery", "salt", "pepper"]	Boil chicken with vegetables. Cook rice in broth. Whisk eggs with lemon. Temper egg mixture. Stir into soup off heat	15	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
89	4	Moussaka	["eggplant", "ground beef", "onion", "garlic", "tomato paste", "red wine", "cinnamon", "nutmeg", "butter", "flour", "milk", "eggs", "parmesan cheese", "olive oil", "salt", "pepper"]	Slice and salt eggplant, let drain 30 min. Brown meat with onions and garlic. Add tomato paste, wine, spices. Make béchamel sauce. Layer eggplant, meat, béchamel. Bake at 180°C for 45 minutes	45	t	2025-09-30 13:15:28.110125+02	2025-09-30 13:15:28.110125+02
12	2	Gigantes Plaki	["giant beans", "onion", "garlic", "tomatoes", "tomato paste", "parsley", "dill", "olive oil", "salt", "pepper"]	Soak beans overnight. Boil until tender. Make tomato sauce. Combine and bake. Garnish with herbs	20	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
13	2	Keftedes	["ground beef", "ground pork", "bread crumbs", "onion", "garlic", "mint", "parsley", "eggs", "ouzo", "flour", "olive oil"]	Mix meats with herbs. Add bread crumbs and egg. Form into balls. Coat with flour. Fry until golden	20	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
14	2	Galaktoboureko	["phyllo dough", "milk", "semolina", "eggs", "sugar", "butter", "vanilla", "lemon zest", "honey", "water"]	Make custard with semolina. Layer phyllo sheets. Add custard filling. Cover with phyllo. Bake and add syrup	40	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
15	2	Melitzanosalata	["eggplant", "garlic", "lemon juice", "olive oil", "parsley", "salt", "pepper"]	Roast eggplants whole. Peel and mash flesh. Mix with garlic and lemon. Drizzle olive oil. Garnish with parsley	15	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
16	2	Loukoumades	["flour", "yeast", "water", "salt", "honey", "cinnamon", "walnuts", "oil for frying"]	Make yeast dough. Let rise 1 hour. Fry spoonfuls in oil. Drizzle with honey. Sprinkle cinnamon and nuts	75	f	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
17	2	Kleftiko	["lamb shoulder", "potatoes", "tomatoes", "onion", "garlic", "lemon", "oregano", "feta cheese", "olive oil", "white wine"]	Season lamb with herbs. Add vegetables. Wrap in parchment. Slow roast 3 hours. Serve with juices	20	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
90	4	Souvlaki	["pork shoulder", "lemon juice", "olive oil", "oregano", "garlic", "salt", "pepper", "pita bread", "tzatziki", "tomatoes", "onions"]	Cut meat into cubes. Marinate with lemon, oil, oregano for 2 hours. Thread onto skewers. Grill 10-12 minutes, turning frequently. Serve in pita with tzatziki	140	t	2025-09-30 13:25:53.391399+02	2025-09-30 13:25:53.391399+02
91	4	Tiropita	["feta cheese", "ricotta cheese", "eggs", "phyllo dough", "butter", "milk", "nutmeg", "pepper"]	Mix cheeses with eggs. Layer phyllo with butter. Add cheese filling. Fold into triangles. Bake until golden	25	t	2025-09-30 13:26:18.122511+02	2025-09-30 13:26:18.122511+02
92	4	Psarosoupa	["white fish", "onion", "carrots", "celery", "potatoes", "lemon juice", "olive oil", "dill", "salt", "pepper"]	Simmer vegetables. Add fish pieces. Cook until tender. Add lemon juice. Garnish with dill	15	f	2025-09-30 13:26:40.535953+02	2025-09-30 13:26:40.535953+02
24	4	Grilled Cheese Sandwich	["bread", "butter", "cheese"]	Butter bread on both sides. Place cheese between slices. Grill in pan until golden brown and cheese melts.	10	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
25	4	Chicken Stir Fry	["chicken", "broccoli", "soy sauce", "garlic", "ginger", "oil", "rice"]	Stir fry chicken with garlic and ginger. Add broccoli. Season with soy sauce. Serve over rice.	15	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
26	4	Tomato Soup	["tomatoes", "onions", "cream", "basil", "garlic", "butter"]	Sauté onions and garlic in butter. Add tomatoes and simmer. Blend until smooth. Add cream and basil.	30	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
105	1	Caesar Salad	["lettuce", "parmesan", "croutons", "caesar dressing", "lemon"]	Toss lettuce with caesar dressing. Top with parmesan and croutons. Squeeze lemon over top.	5	t	2025-10-01 04:04:27.76194+02	2025-10-01 04:04:27.76194+02
106	1	Beef Tacos	["ground beef", "taco shells", "cheese", "lettuce", "tomatoes", "sour cream", "salsa"]	Brown ground beef with taco seasoning. Warm taco shells. Fill with beef and toppings.	20	t	2025-10-01 04:06:32.113048+02	2025-10-01 04:06:32.113048+02
107	1	Pancakes	["flour", "eggs", "milk", "butter", "sugar", "baking powder", "vanilla"]	Mix dry ingredients. Beat in eggs and milk. Cook on griddle until bubbles form. Flip and cook until golden.	15	t	2025-10-01 04:06:32.149583+02	2025-10-01 04:06:32.149583+02
27	5	Caesar Salad	["lettuce", "parmesan", "croutons", "caesar dressing", "lemon"]	Toss lettuce with caesar dressing. Top with parmesan and croutons. Squeeze lemon over top.	5	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
28	5	Beef Tacos	["ground beef", "taco shells", "cheese", "lettuce", "tomatoes", "sour cream", "salsa"]	Brown ground beef with taco seasoning. Warm taco shells. Fill with beef and toppings.	20	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
29	5	Pancakes	["flour", "eggs", "milk", "butter", "sugar", "baking powder", "vanilla"]	Mix dry ingredients. Beat in eggs and milk. Cook on griddle until bubbles form. Flip and cook until golden.	15	t	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
30	4	Caesar Salad	["lettuce", "parmesan", "croutons", "caesar dressing", "lemon"]	Toss lettuce with caesar dressing. Top with parmesan and croutons. Squeeze lemon over top.	5	t	2025-09-29 08:41:50.754585+02	2025-09-29 08:41:50.754585+02
31	4	Beef Tacos	["ground beef", "taco shells", "cheese", "lettuce", "tomatoes", "sour cream", "salsa"]	Brown ground beef with taco seasoning. Warm taco shells. Fill with beef and toppings.	20	t	2025-09-29 08:42:21.763853+02	2025-09-29 08:42:21.763853+02
108	2	Pancakes	["flour", "eggs", "milk", "butter", "sugar", "baking powder", "vanilla"]	Mix dry ingredients. Beat in eggs and milk. Cook on griddle until bubbles form. Flip and cook until golden.	15	t	2025-10-01 04:12:08.809848+02	2025-10-01 04:12:08.809848+02
51	4	Pancakes	["flour", "eggs", "milk", "butter", "sugar", "baking powder", "vanilla"]	Mix dry ingredients. Beat in eggs and milk. Cook on griddle until bubbles form. Flip and cook until golden.	15	t	2025-09-29 08:49:28.469947+02	2025-09-29 08:49:28.469947+02
84	2	Stifado	["beef", "pearl onions", "tomato paste", "red wine", "bay leaves", "cinnamon stick", "cloves", "garlic", "olive oil", "vinegar"]	Brown beef chunks. Sauté whole pearl onions. Add wine and tomatoes. Add spices. Slow cook for 2 hours	30	f	2025-09-29 09:42:24.57665+02	2025-09-29 09:42:24.57665+02
100	4	Bob's Demo Pasta	["pasta", "tomatoes", "garlic", "olive oil"]	Cook pasta. Make sauce. Combine.	20	t	2025-10-01 03:34:11.417442+02	2025-10-01 03:34:11.417442+02
103	2	Bob's Demo Pasta	["pasta", "tomatoes", "garlic", "olive oil"]	Cook pasta. Make sauce. Combine.	20	t	2025-10-01 03:42:27.656097+02	2025-10-01 03:42:27.656097+02
109	1	Mushroom Risotto	["rice", "mushrooms", "onions", "garlic", "white wine", "cheese", "butter", "olive oil"]	1. Sauté mushrooms\n2. Cook risotto slowly\n3. Add cheese and butter\n4. Serve hot	36	t	2025-10-03 10:22:12.322768+02	2025-10-03 10:22:12.322768+02
110	1	Chicken Alfredo	["pasta", "chicken breast", "milk", "cheese", "butter", "garlic", "flour", "salt", "pepper"]	1. Cook pasta and chicken\n2. Make alfredo sauce with butter, flour, milk, and cheese\n3. Combine everything\n4. Season to taste	32	t	2025-10-03 10:22:12.336885+02	2025-10-03 10:22:12.336885+02
111	1	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	56	t	2025-10-03 10:22:12.338597+02	2025-10-03 10:22:12.338597+02
112	1	Seafood Paella	["rice", "shrimp", "mussels", "saffron", "bell peppers", "onions", "garlic", "olive oil", "lemon", "parsley"]	1. Sauté vegetables\n2. Add rice and saffron\n3. Add seafood\n4. Cook until rice is done	54	t	2025-10-03 10:22:12.340194+02	2025-10-03 10:22:12.340194+02
113	1	Buttered Toast	["bread", "butter"]	1. Toast bread\n2. Spread butter on toast	0	t	2025-10-03 10:22:12.341526+02	2025-10-03 10:22:12.341526+02
114	1	French Toast	["bread", "eggs", "milk", "butter", "sugar", "cinnamon", "vanilla"]	1. Mix eggs, milk, sugar, cinnamon, vanilla\n2. Dip bread in mixture\n3. Fry in butter until golden	24	t	2025-10-03 10:22:12.343145+02	2025-10-03 10:22:12.343145+02
115	1	Garlic Bread	["bread", "butter", "garlic", "olive oil", "salt"]	1. Mix butter, garlic, and olive oil\n2. Spread on bread\n3. Bake until golden	22	t	2025-10-03 10:22:12.344511+02	2025-10-03 10:22:12.344511+02
116	1	Carbonara Pasta	["pasta", "eggs", "cheese", "bacon", "garlic", "olive oil", "salt", "pepper"]	1. Cook pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine pasta with egg mixture\n5. Add bacon and season	20	f	2025-10-03 10:22:12.345841+02	2025-10-03 10:22:12.345841+02
117	1	Fish Tacos	["white fish", "tortillas", "cabbage", "lime", "cilantro", "sour cream", "hot sauce"]	1. Cook fish\n2. Warm tortillas\n3. Assemble with toppings	33	f	2025-10-03 10:22:12.347519+02	2025-10-03 10:22:12.347519+02
118	1	Thai Green Curry	["chicken breast", "coconut milk", "green curry paste", "thai basil", "bell peppers", "bamboo shoots", "fish sauce", "sugar"]	1. Fry curry paste\n2. Add coconut milk\n3. Add chicken and vegetables\n4. Simmer until cooked	29	f	2025-10-03 10:22:12.349043+02	2025-10-03 10:22:12.349043+02
119	1	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	15	f	2025-10-03 10:22:12.350947+02	2025-10-03 10:22:12.350947+02
120	1	Loaded Baked Potato	["potatoes", "cheese", "butter", "milk", "bacon", "salt", "pepper", "sour cream"]	1. Bake potatoes\n2. Scoop out inside\n3. Mix with cheese, butter, milk\n4. Refill and top with bacon	62	f	2025-10-03 10:22:12.352577+02	2025-10-03 10:22:12.352577+02
121	1	Scrambled Eggs	["eggs", "butter", "salt", "pepper"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	13	f	2025-10-03 10:22:12.35413+02	2025-10-03 10:22:12.35413+02
122	1	Chicken Parmesan	["chicken breast", "cheese", "tomatoes", "bread crumbs", "eggs", "flour", "olive oil", "basil", "garlic", "salt"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	51	f	2025-10-03 10:22:12.355758+02	2025-10-03 10:22:12.355758+02
123	1	Chicken and Rice	["chicken breast", "rice", "onions", "garlic", "olive oil", "salt", "pepper"]	1. Cook chicken breast\n2. Prepare rice\n3. Sauté onions and garlic\n4. Combine all ingredients	25	f	2025-10-03 10:22:12.357297+02	2025-10-03 10:22:12.357297+02
124	1	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	22	f	2025-10-03 10:22:12.358804+02	2025-10-03 10:22:12.358804+02
125	1	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	21	f	2025-10-03 10:22:12.360291+02	2025-10-03 10:22:12.360291+02
126	4	Scrambled Eggs	["butter", "eggs", "flour", "tomatoes"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	5	f	2025-10-03 10:22:40.416328+02	2025-10-03 10:22:40.416328+02
127	4	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	59	f	2025-10-03 10:22:40.431874+02	2025-10-03 10:22:40.431874+02
128	4	Buttered Toast	["bread", "butter"]	1. Toast bread\n2. Spread butter on toast	2	f	2025-10-03 10:22:40.434207+02	2025-10-03 10:22:40.434207+02
129	4	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper", "truffle oil", "saffron"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	23	f	2025-10-03 10:22:40.436091+02	2025-10-03 10:22:40.436091+02
130	4	Chicken Parmesan	["chicken breast", "cheese", "tomatoes", "bread crumbs", "eggs", "flour", "olive oil", "basil", "garlic", "salt"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	48	f	2025-10-03 10:22:40.437869+02	2025-10-03 10:22:40.437869+02
131	4	Grilled Cheese	["soy sauce", "pasta", "ginger", "chicken", "olive oil"]	1. Butter bread\n2. Add cheese between slices\n3. Grill until golden	7	f	2025-10-03 10:22:40.43991+02	2025-10-03 10:22:40.43991+02
132	4	Fresh Salad	["lettuce", "tomatoes", "olive oil", "salt", "saffron", "quinoa"]	1. Wash and chop lettuce and tomatoes\n2. Drizzle with olive oil\n3. Season with salt	6	f	2025-10-03 10:22:40.441416+02	2025-10-03 10:22:40.441416+02
133	4	Egg Fried Rice	["rice", "eggs", "soy sauce", "olive oil", "salt"]	1. Fry rice\n2. Add beaten eggs\n3. Season with soy sauce	12	f	2025-10-03 10:22:40.443381+02	2025-10-03 10:22:40.443381+02
134	4	Chicken Alfredo	["pasta", "chicken breast", "milk", "cheese", "butter", "garlic", "flour", "salt", "pepper"]	1. Cook pasta and chicken\n2. Make alfredo sauce with butter, flour, milk, and cheese\n3. Combine everything\n4. Season to taste	35	f	2025-10-03 10:22:40.444793+02	2025-10-03 10:22:40.444793+02
135	5	Vegetable Stir Fry	["eggs", "lettuce", "butter", "flour"]	1. Heat oil in wok\n2. Add garlic\n3. Stir fry vegetables\n4. Season to taste	22	t	2025-10-03 10:22:40.446657+02	2025-10-03 10:22:40.446657+02
136	5	Simple Pasta	["pasta", "olive oil", "garlic", "salt"]	1. Cook pasta according to package\n2. Drain and toss with olive oil and garlic\n3. Season with salt	13	t	2025-10-03 10:22:40.44866+02	2025-10-03 10:22:40.44866+02
137	5	Beef Lasagna	["pasta", "ground beef", "tomatoes", "cheese", "onions", "garlic", "olive oil", "basil", "oregano", "salt", "pepper"]	1. Make meat sauce\n2. Layer pasta, meat sauce, and cheese\n3. Bake until bubbly	96	t	2025-10-03 10:22:40.450342+02	2025-10-03 10:22:40.450342+02
138	5	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper", "tahini", "quinoa"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	25	t	2025-10-03 10:22:40.451566+02	2025-10-03 10:22:40.451566+02
139	5	Chicken and Rice	["chicken breast", "rice", "onions", "garlic", "olive oil", "salt", "pepper"]	1. Cook chicken breast\n2. Prepare rice\n3. Sauté onions and garlic\n4. Combine all ingredients	39	t	2025-10-03 10:22:40.453131+02	2025-10-03 10:22:40.453131+02
140	5	Cheese Omelette	["milk", "flour", "ground beef", "butter", "lettuce", "eggs"]	1. Beat eggs with milk\n2. Melt butter in pan\n3. Pour eggs and add cheese\n4. Fold omelette\n5. Season to taste	6	t	2025-10-03 10:22:40.454626+02	2025-10-03 10:22:40.454626+02
141	5	Garlic Bread	["bread", "butter", "garlic", "olive oil", "salt", "quinoa", "saffron"]	1. Mix butter, garlic, and olive oil\n2. Spread on bread\n3. Bake until golden	13	t	2025-10-03 10:22:40.456403+02	2025-10-03 10:22:40.456403+02
142	5	Chicken Caesar Salad	["lettuce", "chicken breast", "cheese", "croutons", "caesar dressing", "lemon"]	1. Grill chicken\n2. Chop lettuce\n3. Mix with dressing\n4. Top with chicken and cheese	21	f	2025-10-03 10:22:40.457872+02	2025-10-03 10:22:40.457872+02
143	5	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	19	f	2025-10-03 10:22:40.459748+02	2025-10-03 10:22:40.459748+02
144	5	Seafood Paella	["rice", "shrimp", "mussels", "saffron", "bell peppers", "onions", "garlic", "olive oil", "lemon", "parsley", "tahini", "saffron"]	1. Sauté vegetables\n2. Add rice and saffron\n3. Add seafood\n4. Cook until rice is done	53	f	2025-10-03 10:22:40.461156+02	2025-10-03 10:22:40.461156+02
145	5	Egg Fried Rice	["cheese", "butter", "eggs", "flour"]	1. Fry rice\n2. Add beaten eggs\n3. Season with soy sauce	13	f	2025-10-03 10:22:40.462516+02	2025-10-03 10:22:40.462516+02
146	5	Chicken Alfredo	["pasta", "chicken breast", "milk", "cheese", "butter", "garlic", "flour", "salt", "pepper"]	1. Cook pasta and chicken\n2. Make alfredo sauce with butter, flour, milk, and cheese\n3. Combine everything\n4. Season to taste	41	f	2025-10-03 10:22:40.464039+02	2025-10-03 10:22:40.464039+02
147	5	Buttered Toast	["bread", "butter", "saffron", "tahini"]	1. Toast bread\n2. Spread butter on toast	10	f	2025-10-03 10:22:40.465524+02	2025-10-03 10:22:40.465524+02
148	5	Fresh Salad	["lettuce", "tomatoes", "olive oil", "salt"]	1. Wash and chop lettuce and tomatoes\n2. Drizzle with olive oil\n3. Season with salt	13	f	2025-10-03 10:22:40.466731+02	2025-10-03 10:22:40.466731+02
149	5	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	45	f	2025-10-03 10:22:40.468142+02	2025-10-03 10:22:40.468142+02
150	5	Mashed Potatoes	["cheese", "ground beef", "milk"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	21	f	2025-10-03 10:22:40.469455+02	2025-10-03 10:22:40.469455+02
151	5	Carbonara Pasta	["pasta", "eggs", "cheese", "bacon", "garlic", "olive oil", "salt", "pepper"]	1. Cook pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine pasta with egg mixture\n5. Add bacon and season	24	f	2025-10-03 10:22:40.470749+02	2025-10-03 10:22:40.470749+02
152	8	Thai Green Curry	["chicken breast", "coconut milk", "green curry paste", "thai basil", "bell peppers", "bamboo shoots", "fish sauce", "sugar"]	1. Fry curry paste\n2. Add coconut milk\n3. Add chicken and vegetables\n4. Simmer until cooked	29	t	2025-10-03 10:22:40.472013+02	2025-10-03 10:22:40.472013+02
153	8	Fish Tacos	["white fish", "tortillas", "cabbage", "lime", "cilantro", "sour cream", "hot sauce"]	1. Cook fish\n2. Warm tortillas\n3. Assemble with toppings	26	t	2025-10-03 10:22:40.473742+02	2025-10-03 10:22:40.473742+02
154	8	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	30	t	2025-10-03 10:22:40.475092+02	2025-10-03 10:22:40.475092+02
155	8	Garlic Bread	["bread", "butter", "garlic", "olive oil", "salt"]	1. Mix butter, garlic, and olive oil\n2. Spread on bread\n3. Bake until golden	18	t	2025-10-03 10:22:40.476101+02	2025-10-03 10:22:40.476101+02
156	8	Chicken Caesar Salad	["lettuce", "chicken breast", "cheese", "croutons", "caesar dressing", "lemon"]	1. Grill chicken\n2. Chop lettuce\n3. Mix with dressing\n4. Top with chicken and cheese	17	t	2025-10-03 10:22:40.477086+02	2025-10-03 10:22:40.477086+02
157	8	Vegetable Stir Fry	["bell peppers", "onions", "carrots", "olive oil", "salt", "pepper", "garlic"]	1. Heat oil in wok\n2. Add garlic\n3. Stir fry vegetables\n4. Season to taste	15	t	2025-10-03 10:22:40.478058+02	2025-10-03 10:22:40.478058+02
158	8	Chicken Parmesan	["chicken breast", "cheese", "tomatoes", "bread crumbs", "eggs", "flour", "olive oil", "basil", "garlic", "salt"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	55	t	2025-10-03 10:22:40.479046+02	2025-10-03 10:22:40.479046+02
159	8	Buttered Toast	["bread", "butter"]	1. Toast bread\n2. Spread butter on toast	3	t	2025-10-03 10:22:40.48036+02	2025-10-03 10:22:40.48036+02
160	8	Simple Pasta	["pasta", "olive oil", "garlic", "salt"]	1. Cook pasta according to package\n2. Drain and toss with olive oil and garlic\n3. Season with salt	17	t	2025-10-03 10:22:40.48228+02	2025-10-03 10:22:40.48228+02
161	8	Cheese Omelette	["eggs", "cheese", "butter", "salt", "pepper", "milk"]	1. Beat eggs with milk\n2. Melt butter in pan\n3. Pour eggs and add cheese\n4. Fold omelette\n5. Season to taste	6	t	2025-10-03 10:22:40.483353+02	2025-10-03 10:22:40.483353+02
162	8	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	60	f	2025-10-03 10:22:40.484313+02	2025-10-03 10:22:40.484313+02
163	8	Egg Fried Rice	["rice", "eggs", "soy sauce", "olive oil", "salt"]	1. Fry rice\n2. Add beaten eggs\n3. Season with soy sauce	14	f	2025-10-03 10:22:40.485602+02	2025-10-03 10:22:40.485602+02
164	8	Seafood Paella	["rice", "shrimp", "mussels", "saffron", "bell peppers", "onions", "garlic", "olive oil", "lemon", "parsley"]	1. Sauté vegetables\n2. Add rice and saffron\n3. Add seafood\n4. Cook until rice is done	49	f	2025-10-03 10:22:40.487009+02	2025-10-03 10:22:40.487009+02
165	8	Beef Lasagna	["pasta", "ground beef", "tomatoes", "cheese", "onions", "garlic", "olive oil", "basil", "oregano", "salt", "pepper"]	1. Make meat sauce\n2. Layer pasta, meat sauce, and cheese\n3. Bake until bubbly	85	f	2025-10-03 10:22:40.48801+02	2025-10-03 10:22:40.48801+02
166	8	Loaded Baked Potato	["potatoes", "cheese", "butter", "milk", "bacon", "salt", "pepper", "sour cream"]	1. Bake potatoes\n2. Scoop out inside\n3. Mix with cheese, butter, milk\n4. Refill and top with bacon	62	f	2025-10-03 10:22:40.488998+02	2025-10-03 10:22:40.488998+02
167	8	Scrambled Eggs	["eggs", "butter", "salt", "pepper"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	15	f	2025-10-03 10:22:40.490033+02	2025-10-03 10:22:40.490033+02
168	8	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	10	f	2025-10-03 10:22:40.490976+02	2025-10-03 10:22:40.490976+02
169	8	Chicken and Rice	["chicken breast", "rice", "onions", "garlic", "olive oil", "salt", "pepper"]	1. Cook chicken breast\n2. Prepare rice\n3. Sauté onions and garlic\n4. Combine all ingredients	28	f	2025-10-03 10:22:40.491952+02	2025-10-03 10:22:40.491952+02
170	8	Carbonara Pasta	["pasta", "eggs", "cheese", "bacon", "garlic", "olive oil", "salt", "pepper"]	1. Cook pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine pasta with egg mixture\n5. Add bacon and season	33	f	2025-10-03 10:22:40.493129+02	2025-10-03 10:22:40.493129+02
171	8	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	24	f	2025-10-03 10:22:40.494293+02	2025-10-03 10:22:40.494293+02
172	9	Scrambled Eggs	["eggs", "butter", "salt", "pepper"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	12	t	2025-10-03 10:22:40.495359+02	2025-10-03 10:22:40.495359+02
173	9	Fish Tacos	["white fish", "tortillas", "cabbage", "lime", "cilantro", "sour cream", "hot sauce"]	1. Cook fish\n2. Warm tortillas\n3. Assemble with toppings	35	t	2025-10-03 10:22:40.496893+02	2025-10-03 10:22:40.496893+02
174	9	Cheese Omelette	["eggs", "cheese", "butter", "salt", "pepper", "milk"]	1. Beat eggs with milk\n2. Melt butter in pan\n3. Pour eggs and add cheese\n4. Fold omelette\n5. Season to taste	5	t	2025-10-03 10:22:40.497878+02	2025-10-03 10:22:40.497878+02
175	9	Buttered Toast	["bread", "butter"]	1. Toast bread\n2. Spread butter on toast	2	t	2025-10-03 10:22:40.498918+02	2025-10-03 10:22:40.498918+02
176	9	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	22	t	2025-10-03 10:22:40.499855+02	2025-10-03 10:22:40.499855+02
177	9	Simple Pasta	["pasta", "olive oil", "garlic", "salt"]	1. Cook pasta according to package\n2. Drain and toss with olive oil and garlic\n3. Season with salt	23	t	2025-10-03 10:22:40.500881+02	2025-10-03 10:22:40.500881+02
178	9	French Toast	["bread", "eggs", "milk", "butter", "sugar", "cinnamon", "vanilla"]	1. Mix eggs, milk, sugar, cinnamon, vanilla\n2. Dip bread in mixture\n3. Fry in butter until golden	17	t	2025-10-03 10:22:40.501848+02	2025-10-03 10:22:40.501848+02
179	9	Mushroom Risotto	["rice", "mushrooms", "onions", "garlic", "white wine", "cheese", "butter", "olive oil"]	1. Sauté mushrooms\n2. Cook risotto slowly\n3. Add cheese and butter\n4. Serve hot	41	t	2025-10-03 10:22:40.50281+02	2025-10-03 10:22:40.50281+02
180	9	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	54	t	2025-10-03 10:22:40.504022+02	2025-10-03 10:22:40.504022+02
181	9	Chicken Caesar Salad	["lettuce", "chicken breast", "cheese", "croutons", "caesar dressing", "lemon"]	1. Grill chicken\n2. Chop lettuce\n3. Mix with dressing\n4. Top with chicken and cheese	16	t	2025-10-03 10:22:40.505014+02	2025-10-03 10:22:40.505014+02
182	9	Beef Lasagna	["pasta", "ground beef", "tomatoes", "cheese", "onions", "garlic", "olive oil", "basil", "oregano", "salt", "pepper"]	1. Make meat sauce\n2. Layer pasta, meat sauce, and cheese\n3. Bake until bubbly	93	f	2025-10-03 10:22:40.505979+02	2025-10-03 10:22:40.505979+02
183	9	Thai Green Curry	["chicken breast", "coconut milk", "green curry paste", "thai basil", "bell peppers", "bamboo shoots", "fish sauce", "sugar"]	1. Fry curry paste\n2. Add coconut milk\n3. Add chicken and vegetables\n4. Simmer until cooked	32	f	2025-10-03 10:22:40.506992+02	2025-10-03 10:22:40.506992+02
184	9	Grilled Cheese	["bread", "cheese", "butter"]	1. Butter bread\n2. Add cheese between slices\n3. Grill until golden	6	f	2025-10-03 10:22:40.50795+02	2025-10-03 10:22:40.50795+02
185	9	Fresh Salad	["lettuce", "tomatoes", "olive oil", "salt"]	1. Wash and chop lettuce and tomatoes\n2. Drizzle with olive oil\n3. Season with salt	12	f	2025-10-03 10:22:40.508878+02	2025-10-03 10:22:40.508878+02
186	9	Garlic Bread	["bread", "butter", "garlic", "olive oil", "salt"]	1. Mix butter, garlic, and olive oil\n2. Spread on bread\n3. Bake until golden	21	f	2025-10-03 10:22:40.50966+02	2025-10-03 10:22:40.50966+02
187	9	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	22	f	2025-10-03 10:22:40.51045+02	2025-10-03 10:22:40.51045+02
188	9	Carbonara Pasta	["pasta", "eggs", "cheese", "bacon", "garlic", "olive oil", "salt", "pepper"]	1. Cook pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine pasta with egg mixture\n5. Add bacon and season	34	f	2025-10-03 10:22:40.511221+02	2025-10-03 10:22:40.511221+02
189	9	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	13	f	2025-10-03 10:22:40.512027+02	2025-10-03 10:22:40.512027+02
190	9	Vegetable Stir Fry	["bell peppers", "onions", "carrots", "olive oil", "salt", "pepper", "garlic"]	1. Heat oil in wok\n2. Add garlic\n3. Stir fry vegetables\n4. Season to taste	20	f	2025-10-03 10:22:40.512763+02	2025-10-03 10:22:40.512763+02
191	9	Seafood Paella	["rice", "shrimp", "mussels", "saffron", "bell peppers", "onions", "garlic", "olive oil", "lemon", "parsley"]	1. Sauté vegetables\n2. Add rice and saffron\n3. Add seafood\n4. Cook until rice is done	41	f	2025-10-03 10:22:40.513501+02	2025-10-03 10:22:40.513501+02
192	10	Beef Lasagna	["pasta", "ground beef", "tomatoes", "cheese", "onions", "garlic", "olive oil", "basil", "oregano", "salt", "pepper"]	1. Make meat sauce\n2. Layer pasta, meat sauce, and cheese\n3. Bake until bubbly	87	t	2025-10-03 10:22:40.514286+02	2025-10-03 10:22:40.514286+02
193	10	Chicken Caesar Salad	["lettuce", "chicken breast", "cheese", "croutons", "caesar dressing", "lemon"]	1. Grill chicken\n2. Chop lettuce\n3. Mix with dressing\n4. Top with chicken and cheese	23	t	2025-10-03 10:22:40.515394+02	2025-10-03 10:22:40.515394+02
194	10	Chicken Parmesan	["chicken breast", "cheese", "tomatoes", "bread crumbs", "eggs", "flour", "olive oil", "basil", "garlic", "salt"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	47	t	2025-10-03 10:22:40.516288+02	2025-10-03 10:22:40.516288+02
195	10	Grilled Cheese	["bread", "cheese", "butter"]	1. Butter bread\n2. Add cheese between slices\n3. Grill until golden	5	t	2025-10-03 10:22:40.517026+02	2025-10-03 10:22:40.517026+02
196	10	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	15	t	2025-10-03 10:22:40.51779+02	2025-10-03 10:22:40.51779+02
197	10	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	35	t	2025-10-03 10:22:40.518535+02	2025-10-03 10:22:40.518535+02
198	10	Fish Tacos	["white fish", "tortillas", "cabbage", "lime", "cilantro", "sour cream", "hot sauce"]	1. Cook fish\n2. Warm tortillas\n3. Assemble with toppings	26	t	2025-10-03 10:22:40.519274+02	2025-10-03 10:22:40.519274+02
199	10	Garlic Bread	["bread", "butter", "garlic", "olive oil", "salt"]	1. Mix butter, garlic, and olive oil\n2. Spread on bread\n3. Bake until golden	11	t	2025-10-03 10:22:40.519975+02	2025-10-03 10:22:40.519975+02
200	10	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	49	t	2025-10-03 10:22:40.520765+02	2025-10-03 10:22:40.520765+02
201	10	Loaded Baked Potato	["potatoes", "cheese", "butter", "milk", "bacon", "salt", "pepper", "sour cream"]	1. Bake potatoes\n2. Scoop out inside\n3. Mix with cheese, butter, milk\n4. Refill and top with bacon	70	t	2025-10-03 10:22:40.521643+02	2025-10-03 10:22:40.521643+02
202	10	Simple Pasta	["pasta", "olive oil", "garlic", "salt"]	1. Cook pasta according to package\n2. Drain and toss with olive oil and garlic\n3. Season with salt	25	f	2025-10-03 10:22:40.522451+02	2025-10-03 10:22:40.522451+02
203	10	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	25	f	2025-10-03 10:22:40.523183+02	2025-10-03 10:22:40.523183+02
204	10	Egg Fried Rice	["rice", "eggs", "soy sauce", "olive oil", "salt"]	1. Fry rice\n2. Add beaten eggs\n3. Season with soy sauce	13	f	2025-10-03 10:22:40.523919+02	2025-10-03 10:22:40.523919+02
205	10	Vegetable Stir Fry	["bell peppers", "onions", "carrots", "olive oil", "salt", "pepper", "garlic"]	1. Heat oil in wok\n2. Add garlic\n3. Stir fry vegetables\n4. Season to taste	25	f	2025-10-03 10:22:40.524699+02	2025-10-03 10:22:40.524699+02
206	10	French Toast	["bread", "eggs", "milk", "butter", "sugar", "cinnamon", "vanilla"]	1. Mix eggs, milk, sugar, cinnamon, vanilla\n2. Dip bread in mixture\n3. Fry in butter until golden	19	f	2025-10-03 10:22:40.525667+02	2025-10-03 10:22:40.525667+02
207	10	Buttered Toast	["bread", "butter"]	1. Toast bread\n2. Spread butter on toast	9	f	2025-10-03 10:22:40.526398+02	2025-10-03 10:22:40.526398+02
208	10	Scrambled Eggs	["eggs", "butter", "salt", "pepper"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	8	f	2025-10-03 10:22:40.527095+02	2025-10-03 10:22:40.527095+02
209	10	Chicken and Rice	["chicken breast", "rice", "onions", "garlic", "olive oil", "salt", "pepper"]	1. Cook chicken breast\n2. Prepare rice\n3. Sauté onions and garlic\n4. Combine all ingredients	27	f	2025-10-03 10:22:40.5278+02	2025-10-03 10:22:40.5278+02
210	10	Chicken Alfredo	["pasta", "chicken breast", "milk", "cheese", "butter", "garlic", "flour", "salt", "pepper"]	1. Cook pasta and chicken\n2. Make alfredo sauce with butter, flour, milk, and cheese\n3. Combine everything\n4. Season to taste	45	f	2025-10-03 10:22:40.528534+02	2025-10-03 10:22:40.528534+02
211	10	Cheese Omelette	["eggs", "cheese", "butter", "salt", "pepper", "milk"]	1. Beat eggs with milk\n2. Melt butter in pan\n3. Pour eggs and add cheese\n4. Fold omelette\n5. Season to taste	12	f	2025-10-03 10:22:40.529262+02	2025-10-03 10:22:40.529262+02
212	2	Chicken Parmesan	["butter", "ginger", "soy sauce"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	52	f	2025-10-03 10:22:40.529988+02	2025-10-03 10:22:40.529988+02
213	15	Beef Lasagna	["bell peppers", "bread", "garlic", "salt", "potatoes"]	1. Make meat sauce\n2. Layer pasta, meat sauce, and cheese\n3. Bake until bubbly	91	t	2025-10-03 10:22:40.531087+02	2025-10-03 10:22:40.531087+02
214	15	Egg Fried Rice	["rice", "eggs", "soy sauce", "olive oil", "salt"]	1. Fry rice\n2. Add beaten eggs\n3. Season with soy sauce	24	t	2025-10-03 10:22:40.532407+02	2025-10-03 10:22:40.532407+02
215	15	Loaded Baked Potato	["potatoes", "cheese", "butter", "milk", "bacon", "salt", "pepper", "sour cream"]	1. Bake potatoes\n2. Scoop out inside\n3. Mix with cheese, butter, milk\n4. Refill and top with bacon	65	t	2025-10-03 10:22:40.53332+02	2025-10-03 10:22:40.53332+02
216	15	Tomato Soup	["tomatoes", "onions", "garlic", "butter", "milk", "salt", "pepper", "truffle oil", "miso paste"]	1. Sauté onions and garlic\n2. Add tomatoes\n3. Blend and add milk\n4. Season to taste	28	t	2025-10-03 10:22:40.534221+02	2025-10-03 10:22:40.534221+02
217	15	Mushroom Risotto	["rice", "mushrooms", "onions", "garlic", "white wine", "cheese", "butter", "olive oil"]	1. Sauté mushrooms\n2. Cook risotto slowly\n3. Add cheese and butter\n4. Serve hot	42	t	2025-10-03 10:22:40.535093+02	2025-10-03 10:22:40.535093+02
218	15	Thai Green Curry	["potatoes", "flour", "milk", "pasta"]	1. Fry curry paste\n2. Add coconut milk\n3. Add chicken and vegetables\n4. Simmer until cooked	34	t	2025-10-03 10:22:40.535961+02	2025-10-03 10:22:40.535961+02
219	15	Cheese Omelette	["eggs", "cheese", "butter", "salt", "pepper", "milk", "saffron", "tahini"]	1. Beat eggs with milk\n2. Melt butter in pan\n3. Pour eggs and add cheese\n4. Fold omelette\n5. Season to taste	9	t	2025-10-03 10:22:40.536864+02	2025-10-03 10:22:40.536864+02
220	15	Mashed Potatoes	["potatoes", "butter", "milk", "salt", "pepper"]	1. Boil potatoes\n2. Mash with butter and milk\n3. Season to taste	16	t	2025-10-03 10:22:40.537728+02	2025-10-03 10:22:40.537728+02
221	15	Caprese Salad	["tomatoes", "mozzarella", "basil", "olive oil", "balsamic vinegar", "salt"]	1. Slice tomatoes and mozzarella\n2. Layer with basil\n3. Drizzle with oil and vinegar	12	t	2025-10-03 10:22:40.53859+02	2025-10-03 10:22:40.53859+02
222	15	Spinach Quiche	["eggs", "milk", "cheese", "spinach", "pie crust", "onions", "salt", "pepper", "miso paste", "truffle oil"]	1. Mix eggs, milk, cheese\n2. Add spinach and onions\n3. Pour into crust\n4. Bake until set	49	t	2025-10-03 10:22:40.539479+02	2025-10-03 10:22:40.539479+02
223	15	Scrambled Eggs	["potatoes", "bell peppers", "carrots", "garlic", "tomatoes"]	1. Beat eggs in a bowl\n2. Melt butter in pan\n3. Pour eggs in pan and scramble\n4. Season with salt and pepper	3	f	2025-10-03 10:22:40.540361+02	2025-10-03 10:22:40.540361+02
224	15	Chicken Parmesan	["chicken breast", "cheese", "tomatoes", "bread crumbs", "eggs", "flour", "olive oil", "basil", "garlic", "salt"]	1. Bread chicken\n2. Fry until golden\n3. Top with tomato sauce and cheese\n4. Bake until cheese melts	48	f	2025-10-03 10:22:40.541251+02	2025-10-03 10:22:40.541251+02
225	15	Chicken Caesar Salad	["lettuce", "chicken breast", "cheese", "croutons", "caesar dressing", "lemon", "saffron", "truffle oil"]	1. Grill chicken\n2. Chop lettuce\n3. Mix with dressing\n4. Top with chicken and cheese	25	f	2025-10-03 10:22:40.542174+02	2025-10-03 10:22:40.542174+02
226	15	Grilled Cheese	["bread", "cheese", "butter"]	1. Butter bread\n2. Add cheese between slices\n3. Grill until golden	4	f	2025-10-03 10:22:40.543058+02	2025-10-03 10:22:40.543058+02
227	15	Simple Pasta	["pasta", "olive oil", "garlic", "salt"]	1. Cook pasta according to package\n2. Drain and toss with olive oil and garlic\n3. Season with salt	19	f	2025-10-03 10:22:40.543969+02	2025-10-03 10:22:40.543969+02
228	15	Seafood Paella	["bell peppers", "tomatoes", "olive oil", "chicken breast"]	1. Sauté vegetables\n2. Add rice and saffron\n3. Add seafood\n4. Cook until rice is done	46	f	2025-10-03 10:22:40.544876+02	2025-10-03 10:22:40.544876+02
229	15	French Toast	["bread", "eggs", "milk", "butter", "sugar", "cinnamon", "vanilla"]	1. Mix eggs, milk, sugar, cinnamon, vanilla\n2. Dip bread in mixture\n3. Fry in butter until golden	17	f	2025-10-03 10:22:40.545818+02	2025-10-03 10:22:40.545818+02
230	15	Chicken and Rice	["chicken breast", "rice", "onions", "garlic", "olive oil", "salt", "pepper"]	1. Cook chicken breast\n2. Prepare rice\n3. Sauté onions and garlic\n4. Combine all ingredients	25	f	2025-10-03 10:22:40.546717+02	2025-10-03 10:22:40.546717+02
231	15	Buttered Toast	["bread", "butter", "saffron", "miso paste"]	1. Toast bread\n2. Spread butter on toast	4	f	2025-10-03 10:22:40.547819+02	2025-10-03 10:22:40.547819+02
232	15	Carbonara Pasta	["pasta", "eggs", "cheese", "bacon", "garlic", "olive oil", "salt", "pepper"]	1. Cook pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine pasta with egg mixture\n5. Add bacon and season	27	f	2025-10-03 10:22:40.548693+02	2025-10-03 10:22:40.548693+02
\.


--
-- Data for Name: user_pantry; Type: TABLE DATA; Schema: public; Owner: David
--

COPY public.user_pantry (id, user_id, ingredients_json, created_at, updated_at) FROM stdin;
4	5	["butter", "lettuce", "ground beef", "cheese", "flour", "eggs", "milk"]	2025-09-29 01:37:31.583683+02	2025-09-29 01:37:31.583683+02
1	2	["butter", "cheese", "chicken", "eggs", "flour", "garlic", "ginger", "milk", "olive oil", "onions", "pasta", "rice", "soy sauce", "tomatoes"]	2025-09-29 01:37:31.583683+02	2025-10-01 03:35:16.108484+02
3	4	["butter", "cheese", "chicken", "eggs", "flour", "garlic", "ginger", "milk", "olive oil", "onions", "pasta", "rice", "soy sauce", "tomatoes"]	2025-09-29 01:37:31.583683+02	2025-10-01 03:53:40.104824+02
7	15	["bell peppers", "bread", "butter", "carrots", "cheese", "chicken breast", "eggs", "flour", "garlic", "lettuce", "milk", "olive oil", "onions", "pasta", "pepper", "potatoes", "rice", "salt", "sugar", "tomatoes"]	2025-10-03 10:05:56.187005+02	2025-10-03 10:05:56.187005+02
10	1	["baking powder", "baking soda", "brown sugar", "butter", "chocolate chips", "cinnamon", "cocoa powder", "cream", "eggs", "flour", "honey", "milk", "nutmeg", "salt", "sugar", "vanilla", "vegetable oil", "yeast"]	2025-10-03 10:34:25.771191+02	2025-10-03 10:34:25.771191+02
11	8	["beans", "bell peppers", "cheese", "chickpeas", "eggs", "flour", "garlic", "lemon", "lentils", "milk", "mushrooms", "nuts", "olive oil", "onions", "pasta", "quinoa", "rice", "seeds", "spinach", "tofu", "tomatoes", "vegetables"]	2025-10-03 10:34:25.778731+02	2025-10-03 10:34:25.778731+02
12	9	["basil", "bell peppers", "bread", "capers", "cheese", "chicken breast", "eggs", "flour", "garlic", "lemon", "mozzarella", "olive oil", "olives", "onions", "oregano", "parsley", "pasta", "pepper", "salt", "tomatoes", "wine vinegar"]	2025-10-03 10:34:25.782748+02	2025-10-03 10:34:25.782748+02
13	10	["basil", "bell peppers", "bread", "capers", "cheese", "eggs", "flour", "garlic", "lemon", "mozzarella", "olive oil", "olives", "onions", "oregano", "parsley", "pasta", "pepper", "salt", "tomatoes", "wine vinegar"]	2025-10-03 10:34:25.785002+02	2025-10-03 10:34:25.785002+02
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: David
--

COPY public.users (id, email, username, role, password_hash, created_at, updated_at) FROM stdin;
4	bob@demo.com	bob	user	$2b$12$xIUtqZBSIuozzTc3l9wOhuWyKjbXfzB88o/..1Gp.oNA7VRdCdE2m	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
5	charlie@demo.com	charlie	user	$2b$12$aCBNC7NPsuRM62OG3TAFQubffWvOObduP1x1BQ9XXeCe4s8uRYUp2	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
8	user1_new@example.com	use1_nu	user	$2b$12$ndM97wr.AJ85S9P9JQUB7O..cUrrF9nYc7tK1qaeasvVoAYkGtyZO	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
9	3trees@example.com	treesfor3	user	$2b$12$oNm7OwFY.Ldzh5RgK8XBHu05PxhNIQ22emDGQlF4yd5X7B4qnb0Oa	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
10	admin-two@recipe-pantry.com	admin-two	admin	$2b$12$4H3RdNrbVIGlLcQDUiX/iueLjL5CWy6ebB7Nd6HtqiV9ddBiYB4kq	2025-09-29 02:00:17.539719+02	2025-09-29 02:00:17.539719+02
15	alice@demo.com	alice	user	$2b$12$gXeCbAWa7UbXMgA3VJ0ITeyO7KiyzRrIu1fYgPTeMgi0xxTxr/V/2	2025-09-30 14:43:04.376866+02	2025-09-30 14:43:04.376866+02
1	admin@recipe-pantry.com	admin	admin	$2b$12$MrL0JimkNOv8hkSHk08.hu9bdStHDH0UvAwAgVOugCkZniaS1qKRG	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
2	manos@masterschool.com	manos	user	$2b$12$cAa8oR6ox7RfBxS54cCtlO/GT/0eDb8iw9s5oHUZwFOEGc4xgtJVO	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
\.


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: David
--

SELECT pg_catalog.setval('public.recipes_id_seq', 52, true);


--
-- Name: user_pantry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: David
--

SELECT pg_catalog.setval('public.user_pantry_id_seq', 26, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: David
--

SELECT pg_catalog.setval('public.users_id_seq', 30, true);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: recipes unique_recipe_title_per_user; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT unique_recipe_title_per_user UNIQUE (user_id, title);


--
-- Name: user_pantry user_pantry_pkey; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_pkey PRIMARY KEY (id);


--
-- Name: user_pantry user_pantry_user_id_key; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_user_id_key UNIQUE (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_recipes_is_public; Type: INDEX; Schema: public; Owner: David
--

CREATE INDEX idx_recipes_is_public ON public.recipes USING btree (is_public);


--
-- Name: idx_recipes_user_id; Type: INDEX; Schema: public; Owner: David
--

CREATE INDEX idx_recipes_user_id ON public.recipes USING btree (user_id);


--
-- Name: idx_user_pantry_user_id; Type: INDEX; Schema: public; Owner: David
--

CREATE INDEX idx_user_pantry_user_id ON public.user_pantry USING btree (user_id);


--
-- Name: recipes recipes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_pantry user_pantry_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: David
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 5MFdTWmFD59flMbLvdif1fZbL4BWZnqkgnDGuUbixl00QK3bqIzpbrVffCZvtSP
