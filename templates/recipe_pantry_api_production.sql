--
-- Recipe Pantry API - Production Database
-- ========================================
--
-- This SQL file creates the complete database structure and data
-- for the Recipe Pantry API bootcamp project.
--
-- IMPORTANT: User passwords are hashed with bcrypt.
-- Actual passwords are stored securely outside version control.
-- Contact the project owner for test account credentials.
--
-- Database contents:
-- - 8 user accounts (2 admin, 6 regular users including instructor)
-- - 160 recipes with full instructions
-- - 2080 ingredients with FDA-compliant names and synonyms
-- - Recipe-ingredient mappings
-- - User pantry data
--
-- To restore this database:
-- psql -U username -d database_name < recipe_pantry_api_production.sql
--

--
-- PostgreSQL database dump
--


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

ALTER TABLE IF EXISTS ONLY public.user_pantry DROP CONSTRAINT IF EXISTS user_pantry_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_pantry DROP CONSTRAINT IF EXISTS user_pantry_ingredient_id_fkey;
ALTER TABLE IF EXISTS ONLY public.recipes DROP CONSTRAINT IF EXISTS recipes_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_recipe_id_fkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_ingredient_id_fkey;
DROP INDEX IF EXISTS public.idx_user_pantry_user_id;
DROP INDEX IF EXISTS public.idx_user_pantry_ingredient_id;
DROP INDEX IF EXISTS public.idx_recipes_user_id;
DROP INDEX IF EXISTS public.idx_recipes_is_public;
DROP INDEX IF EXISTS public.idx_recipe_ingredients_recipe_id;
DROP INDEX IF EXISTS public.idx_recipe_ingredients_ingredient_id;
DROP INDEX IF EXISTS public.idx_ingredients_name;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_pantry DROP CONSTRAINT IF EXISTS user_pantry_pkey;
ALTER TABLE IF EXISTS ONLY public.user_pantry DROP CONSTRAINT IF EXISTS unique_user_ingredient;
ALTER TABLE IF EXISTS ONLY public.recipes DROP CONSTRAINT IF EXISTS unique_recipe_title_per_user;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS unique_recipe_ingredient;
ALTER TABLE IF EXISTS ONLY public.ingredients DROP CONSTRAINT IF EXISTS unique_ingredient_name;
ALTER TABLE IF EXISTS ONLY public.recipes DROP CONSTRAINT IF EXISTS recipes_pkey;
ALTER TABLE IF EXISTS ONLY public.recipe_ingredients DROP CONSTRAINT IF EXISTS recipe_ingredients_pkey;
ALTER TABLE IF EXISTS ONLY public.ingredients DROP CONSTRAINT IF EXISTS ingredients_pkey;
ALTER TABLE IF EXISTS public.recipe_ingredients ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ingredients ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.user_pantry;
DROP SEQUENCE IF EXISTS public.user_pantry_id_seq;
DROP TABLE IF EXISTS public.recipes;
DROP SEQUENCE IF EXISTS public.recipes_id_seq;
DROP SEQUENCE IF EXISTS public.recipe_ingredients_id_seq;
DROP TABLE IF EXISTS public.recipe_ingredients;
DROP SEQUENCE IF EXISTS public.ingredients_id_seq;
DROP TABLE IF EXISTS public.ingredients;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredients (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    synonyms jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: TABLE ingredients; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ingredients IS 'Culinary ingredients - research-verified for accuracy and compliance (2025)';


--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- Name: recipe_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipe_ingredients (
    id integer NOT NULL,
    recipe_id integer NOT NULL,
    ingredient_id integer NOT NULL,
    ingredient_name character varying(100) NOT NULL,
    recipe_name character varying(255) NOT NULL
);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipe_ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: user_pantry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_pantry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_pantry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_pantry (
    id integer DEFAULT nextval('public.user_pantry_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ingredient_id integer NOT NULL,
    ingredient_name character varying(100) NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


--
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ingredients (id, name, synonyms) FROM stdin;
1160	green beans	["green beans", "string beans", "snap beans", "french beans", "haricots verts", "phaseolus vulgaris", "not runner beans"]
11	bell peppers	["bell peppers", "bell pepper", "sweet pepper", "capsicum", "paprika (uk)", "pepper", "sweet peppers", "bell capsicum"]
43	garlic	["garlic", "garlic cloves", "fresh garlic", "garlic bulb", "allium sativum", "garlic heads", "whole garlic"]
9	beans	["common beans", "dried beans", "legumes"]
10	beef	["beef", "beef meat", "cow meat", "bovine meat", "red meat", "ground beef", "beef roast"]
39	eggs	["eggs", "egg", "chicken eggs", "whole eggs", "fresh eggs", "hen eggs", "shell eggs"]
14	broccoli	["broccoli florets", "calabrese"]
16	butter	["salted butter", "unsalted butter", "sweet cream butter", "clarified butter"]
17	cabbage	["green cabbage", "white cabbage", "head cabbage"]
56	lemon	["lemon", "lemons", "fresh lemon", "lemon fruit", "yellow lemon", "citrus lemon", "sour lemon"]
62	milk	["milk", "whole milk", "cow's milk", "dairy milk", "fresh milk", "2% milk", "skim milk"]
7	basil	["basil", "sweet basil", "genovese basil", "italian basil", "ocimum basilicum", "fresh basil", "basil leaves"]
21	celery	["celery stalks", "celery ribs"]
23	chicken	["whole chicken", "chicken meat", "poultry"]
42	flour	["flour", "all-purpose flour", "plain flour", "wheat flour", "white flour", "baking flour", "ap flour"]
22	cheese	["cheddar", "american cheese", "processed cheese", "cheese slices"]
35	cucumber	["cucumbers", "english cucumber", "persian cucumber", "seedless cucumber"]
45	ginger	["fresh ginger", "ginger root", "gingerroot", "zingiber officinale"]
29	cinnamon stick	["cinnamon sticks", "cinnamon bark", "cinnamon quill"]
832	wa38 apples	["wa38 apples", "washington apples", "wa38 cultivar", "note: cosmic crisp is a registered trademark"]
33	cream	["heavy cream", "whipping cream", "double cream", "single cream"]
37	dill	["fresh dill", "dill weed", "dill fronds"]
49	green pepper	["green bell pepper", "green capsicum", "green sweet pepper"]
57	lemon juice	["fresh lemon juice", "lemon concentrate", "juice of lemon"]
58	lemon zest	["lemon peel", "grated lemon peel", "lemon rind"]
60	lettuce	["salad greens", "iceberg lettuce", "romaine lettuce", "green leaf lettuce"]
61	lime	["limes", "fresh lime", "key lime"]
63	mint	["fresh mint", "spearmint", "peppermint", "mint leaves"]
65	mozzarella	["mozzarella cheese", "fresh mozzarella", "buffalo mozzarella", "shredded mozzarella"]
69	nuts	["mixed nuts", "tree nuts", "assorted nuts"]
70	oil	["cooking oil", "vegetable oil", "canola oil"]
27	cilantro	["cilantro", "fresh cilantro", "cilantro leaves", "mexican parsley", "chinese parsley", "fresh coriander", "coriander herb", "dhania leaves"]
856	crème fraîche	["crème fraîche", "fraiche", "french sour cream", "fresh cream cultured", "thickened cream cultured"]
1199	gruyère	["alpine gruyere", "comte alternative", "french gruyere", "gruyère", "swiss gruyere"]
1740	pont-l'évêque	["french monastery cheese", "normandy cheese", "pungent mild cheese", "square soft cheese", "washed pont"]
1870	requesón	["cottage cheese mexican", "fresh cheese mexican ricotta", "latin ricotta", "mexican ricotta", "requesón"]
1205	habanero peppers	["habanero peppers", "habanero", "habaneros", "habanero chiles", "mexican habanero", "capsicum chinense"]
71	oil for frying	["frying oil", "deep frying oil", "vegetable oil"]
593	baby broccoli	["baby broccoli", "long-stem broccoli", "broccolini-type", "tenderstem-type", "sprouting broccoli", "note: broccolini and tenderstem are registered trademarks"]
1711	cripps pink apples	["cripps pink apples", "cripps pink", "pink apples", "rosy apples", "note: pink lady is a registered trademark"]
1577	chocolate hazelnut spread	["chocolate hazelnut spread", "hazelnut cocoa spread", "gianduja spread", "italian chocolate spread", "note: nutella is a registered trademark"]
82	pearl onions	["baby onions", "small onions", "cocktail onions", "pickled onions"]
83	pepper	["black pepper", "ground pepper", "cracked pepper", "peppercorns"]
2384	yam	["yam", "yams", "true yam", "african yam", "white yam", "water yam", "dioscorea", "not sweet potatoes"]
1557	nasturtium	["nasturtium", "garden nasturtium", "indian cress", "nasturtium flowers", "tropaeolum majus", "not watercress"]
38	eggplant	["eggplant", "aubergine", "brinjal", "melongene", "garden egg", "baigan", "egg plant", "purple eggplant"]
433	arugula	["arugula", "rocket", "garden rocket", "roquette", "rucola", "rugula", "salad rocket", "rocket lettuce"]
92	red wine	["dry red wine", "cooking wine", "wine"]
93	rice	["white rice", "long grain rice", "short grain rice", "jasmine rice"]
1174	green onions	["green onions", "scallions", "spring onions", "bunching onions", "salad onions", "green shallots", "scallion"]
354	mct oil	["bulletproof oil", "fractionated coconut oil", "keto oil", "mct coconut", "medium chain triglyceride oil"]
2279	watercress	["watercress", "water cress", "yellowcress", "brook lettuce", "nasturtium officinale", "not garden nasturtium"]
98	seeds	["mixed seeds", "sunflower seeds", "pumpkin seeds", "sesame seeds"]
20	carrots	["carrots", "baby carrots", "carrot", "fresh carrots", "orange carrots", "table carrots", "whole carrots"]
89	potatoes	["potatoes", "potato", "russet potatoes", "white potatoes", "spuds", "baking potatoes", "taters"]
103	spinach	["fresh spinach", "baby spinach", "spinach leaves"]
104	sugar	["white sugar", "granulated sugar", "caster sugar", "refined sugar"]
1319	makrut lime leaves	["makrut lime leaves", "thai lime leaves", "citrus leaves", "kaffir lime leaves (obsolete - offensive)"]
1320	makrut limes	["makrut limes", "thai limes", "bumpy limes", "citrus hystrix", "kaffir limes (obsolete - offensive)"]
2385	coriander	["coriander", "fresh coriander", "coriander leaves", "green coriander", "uk term for cilantro", "not coriander seeds"]
819	coriander seeds	["coriander seeds", "coriander spice", "ground coriander", "coriander powder", "whole coriander", "dhania seeds", "not cilantro leaves"]
2386	canistel	["canistel", "eggfruit", "yellow sapote", "pouteria campechiana", "tiesa", "zapote amarillo", "not lucuma"]
1419	lucuma	["lucuma", "peruvian lucuma", "gold lucuma", "pouteria lucuma", "lucmo", "not canistel"]
115	vanilla	["vanilla extract", "pure vanilla", "vanilla essence", "vanilla flavoring"]
117	vegetables	["mixed vegetables", "fresh vegetables", "veggie mix"]
601	brussels sprouts	["brussels sprouts", "brussel sprouts", "sprouts", "baby cabbages", "brassica oleracea"]
122	white fish	["white fish fillets", "cod", "haddock", "halibut", "tilapia"]
123	white wine	["dry white wine", "cooking white wine", "white table wine"]
124	wine vinegar	["red wine vinegar", "white wine vinegar", "wine-based vinegar"]
74	onion	["onion", "onions", "yellow onion", "white onion", "brown onion", "cooking onion", "storage onions", "allium cepa"]
351	00 flour	["doppio zero", "double zero flour", "italian 00", "pasta flour 00", "pizza flour 00"]
352	1% milk	["light milk", "low fat milk 1%", "one percent milk", "reduced fat 1%", "skim plus milk"]
353	2% milk	["low fat milk", "part skim milk", "reduced fat milk", "semi-skimmed milk", "two percent milk"]
355	a2 milk	["a2 dairy milk", "a2 protein milk", "beta casein a2", "easier digest milk", "natural a2"]
356	abalone	["awabi", "ear shell", "fresh abalone", "haliotis", "sea ear"]
357	acacia honey	["clear honey", "hungarian honey", "light honey acacia", "locust honey", "mild acacia"]
359	acerola	["azarole", "barbados cherry", "cereza", "malpighia", "west indian cherry"]
360	acini di pepe	["italian couscous", "pastina", "peppercorn pasta", "soup pasta tiny", "tiny balls"]
361	ackee	["akee", "blighia", "jamaican ackee", "tropical ackee", "vegetable brain"]
362	ackee fresh	["fresh akee", "fresh blighia", "fresh vegetable brain", "jamaican ackee fresh", "ripe ackee"]
358	açaí berries	["acai", "acai palm fruit", "amazon berries", "purple berries", "superfruit acai"]
1394	lima beans	["lima beans", "butter beans", "fresh lima beans", "madagascar beans", "sieva beans", "chad beans", "baby lima beans", "phaseolus lunatus"]
363	acorn flour	["acorn meal", "dotori flour", "korean acorn flour", "leached acorn flour", "oak flour"]
364	acorn squash	["acorn", "des moines squash", "pepper squash", "table queen squash", "winter squash acorn"]
365	active dry yeast	["active yeast", "baker yeast dry", "bread yeast", "dry yeast granules", "instant yeast alternative"]
366	adobo seasoning	["adobo spice", "goya adobo style", "latin seasoning", "puerto rican seasoning", "sazon alternative"]
367	adzuki beans	["aduki beans", "azuki beans", "dried adzuki", "red beans asian", "sweet red beans"]
368	adzuki sprouts	["azuki sprouts", "germinated adzuki", "japanese bean sprouts", "red bean sprouts", "sprouted adzuki"]
369	agar	["agar agar strips", "dried agar", "gelidium", "sea gelatin", "vegetable gelatin seaweed"]
370	agar agar	["agar powder", "kanten", "seaweed gelatin", "vegan gelatin", "vegetable gelatin"]
371	agave nectar	["agave syrup", "blue agave", "light agave nectar", "mexican sweetener", "raw agave"]
372	aged goat cheese	["aged chevre", "firm goat cheese", "goat cheddar", "hard goat cheese", "vintage chevre"]
373	aged gouda	["crystallized gouda", "extra aged gouda", "hard gouda", "old gouda", "vintage gouda"]
374	aioli	["french garlic sauce", "garlic aioli", "garlic mayonnaise", "mediterranean aioli", "provencal mayo"]
375	aji amarillo	["aji pepper", "golden pepper", "peruvian yellow pepper", "south american pepper", "yellow chili"]
376	aji panca	["burgundy pepper", "dried panca", "mild peruvian pepper", "panca chili", "peruvian red pepper"]
377	ajwain seeds	["ajowan", "bishops weed", "carom seeds", "omam", "thymol seeds"]
378	albacore tuna	["albacore", "canned tuna fish", "longfin tuna", "tombo", "white tuna"]
379	aleppo pepper	["aleppo chili flakes", "halaby pepper", "marash pepper", "pul biber", "syrian pepper"]
380	alfalfa sprouts	["alfalfa", "fresh sprouts", "lucerne sprouts", "sandwich sprouts", "sprouted alfalfa"]
381	alfredo sauce	["cream sauce", "fettuccine sauce", "italian white sauce", "parmesan cream sauce", "white sauce"]
382	alfredo sauce mix	["creamy alfredo mix", "instant alfredo", "knorr alfredo", "pasta sauce mix alfredo", "white sauce mix"]
383	algae oil	["algal oil", "dha oil", "microalgae oil", "seaweed oil", "vegan omega oil"]
384	all purpose flour	["ap flour", "general flour", "multipurpose flour", "plain flour", "white flour"]
385	alligator meat	["alligator tail", "cajun alligator", "farmed alligator", "gator meat", "white alligator meat"]
386	allspice	["allspice berries ground", "ground allspice", "jamaican pepper", "myrtle pepper", "pimento"]
387	allspice berries	["four spices", "jamaican allspice", "pimenta dioica", "pimento berries", "whole allspice"]
388	almond bark	["confectionery bark", "dipping chocolate", "vanilla almond bark", "vanilla flavored coating", "white coating chocolate"]
389	almond butter	["creamy almond butter", "natural almond butter", "raw almond butter", "smooth almond butter", "unsweetened almond butter"]
390	almond extract	["almond essence", "almond flavoring", "amaretto flavoring", "bitter almond extract", "natural almond extract"]
391	almond flour	["almond meal", "almond powder", "blanched almond flour", "ground almonds", "nut flour"]
392	almond milk	["almond beverage", "dairy free almond", "nut milk almond", "unsweetened almond milk", "vanilla almond milk"]
393	almond oil	["cooking almond oil", "nut oil almond", "pressed almond oil", "refined almond oil", "sweet almond oil"]
394	almond paste	["50 percent almond paste", "almond filling", "baking almond paste", "marzipan base", "smooth almond paste"]
395	almond yogurt	["almond milk yogurt", "dairy free almond yogurt", "nut yogurt almond", "plant almond yogurt", "vegan almond yogurt"]
76	oregano	["dried oregano", "mediterranean oregano", "greek oregano"]
397	amaranth	["amaranth grain", "ancient amaranth", "kiwicha", "love-lies-bleeding", "pseudo-cereal"]
398	amaranth greens	["callaloo greens", "chinese spinach", "green amaranth", "pigweed greens", "red amaranth"]
399	amaranth seeds	["amaranth grain", "ancient amaranth", "kiwicha seeds", "popped amaranth", "tiny grain"]
400	ambrosia apples	["ambrosia", "bc apples", "canadian ambrosia", "honey apples", "sweet ambrosia"]
401	anaheim peppers	["california green chile", "hatch peppers", "long green chile", "new mexico peppers", "rio grande peppers"]
402	anasazi beans	["aztec beans", "cave beans", "dried anasazi", "jacob cattle alternative", "new mexico appaloosa"]
403	ancho chilies	["ancho chiles", "chile ancho", "dried poblano", "mexican ancho", "pasilla peppers ancho"]
404	anchovies	["anchovy", "boquerones", "european anchovy", "fresh anchovies", "white anchovies"]
405	anchovy fillets	["anchovy filets", "canned anchovies", "mediterranean anchovies", "oil packed anchovies", "salted anchovies"]
406	anchovy oil	["caesar oil", "fish oil cooking", "mediterranean fish oil", "savory anchovy", "umami oil"]
407	andouille sausage	["cajun sausage", "creole sausage", "louisiana sausage", "smoked andouille", "spicy smoked sausage"]
408	angel hair pasta	["angel hair", "capellini", "cappellini", "fine spaghetti", "thin pasta"]
409	anise seeds	["aniseed", "licorice seeds", "pimpinella seeds", "star anise alternative", "sweet cumin"]
410	anjou pears	["anjou", "beurre anjou", "green anjou", "red anjou", "winter pears"]
411	annatto powder	["achiote powder", "bixa powder", "natural food color", "red coloring powder", "sazon coloring"]
412	annatto seeds	["achiote seeds", "annatto whole", "bixa seeds", "coloring seeds", "roucou"]
413	antelope	["american antelope", "antelope meat", "game antelope", "pronghorn", "wild antelope"]
414	appaloosa beans	["dried appaloosa", "new mexico beans", "pinto type", "speckled beans", "spotted beans"]
415	appenzeller	["herbed swiss cheese", "monastery cheese swiss", "spicy swiss", "swiss appenzeller", "washed appenzeller"]
416	apple butter	["apple spread", "concentrated apple sauce", "fall apple butter", "smooth apple butter", "spiced apple butter"]
417	apple cider vinegar	["acv", "apple vinegar", "bragg acv style", "cider vinegar", "unfiltered apple cider vinegar"]
77	ouzo	["greek ouzo", "anise liqueur", "anisette"]
418	apple pie spice	["apple spice blend", "autumn apple spice", "baking spice apple", "cinnamon spice mix", "warm apple blend"]
419	apples	["apple", "eating apples", "fresh apples", "table apples", "whole apples"]
420	applesauce	["apple sauce", "chunky applesauce", "smooth applesauce", "sweetened applesauce", "unsweetened applesauce"]
421	apricot kernel oil	["apricot oil", "apricot seed oil", "armenian oil", "light nut oil", "prunus armeniaca"]
422	apricots	["apricot", "fresh apricots", "orange apricots", "stone fruit apricot", "tree apricots"]
423	arame	["brown seaweed mild", "dried arame", "eisenia", "japanese arame", "sea oak"]
424	arbol peppers	["arbol chiles", "birds beak chile", "chile de arbol", "rats tail chile", "tree chiles"]
425	arborio rice	["carnaroli alternative", "creamy rice", "italian rice", "risotto rice", "short grain arborio"]
426	arctic char	["alpine char", "arctic trout", "char", "charr", "northern char"]
427	arctic cod	["arctic fish", "ice cod", "northern cod", "polar cod", "tomcod"]
428	argan oil	["argan kernel oil", "cooking argan oil", "liquid gold", "moroccan oil culinary", "pressed argan"]
429	arrabbiata sauce	["angry sauce", "chili pasta sauce", "hot marinara", "italian spicy sauce", "spicy tomato sauce"]
430	arrowhead	["duck potato", "katniss", "sagittaria", "swamp potato", "wapato"]
431	arrowroot flour	["arrowroot meal", "arrowroot powder", "arrowroot starch", "maranta starch", "west indian arrowroot"]
432	artichoke hearts	["artichoke bottoms", "artichokes", "french artichokes", "globe artichokes", "green artichokes"]
78	parmesan	["parmigiano-reggiano", "parmesan cheese", "parm", "grated parmesan"]
434	asafoetida	["asafetida powder", "devils dung", "ferula", "food of the gods", "hing"]
435	ascorbic acid	["antioxidant powder", "bread improver ascorbic", "dough conditioner", "preservative ascorbic", "vitamin c powder"]
436	ash gourd	["chinese winter melon", "dong gua", "wax gourd", "white pumpkin", "winter melon"]
437	asiago cheese	["aged asiago", "asiago pressato", "fresh asiago", "italian asiago", "mountain cheese asiago"]
438	asian pears	["apple pears", "asian pear", "chinese pears", "japanese pears", "nashi pears"]
439	asian sesame dressing	["asian salad dressing", "chinese restaurant dressing", "ginger sesame dressing", "oriental dressing", "sesame ginger vinaigrette"]
440	asparagus spears	["asparagus", "asparagus tips", "fresh asparagus", "garden asparagus", "green asparagus"]
441	ataulfo mangoes	["ataulfo", "champagne mangoes", "honey mangoes", "manila mangoes", "yellow mangoes ataulfo"]
442	atemoya	["annona hybrid", "custard apple hybrid", "pineapple sugar apple", "premium custard", "tropical atemoya"]
443	atemoya fresh	["fresh annona hybrid", "fresh custard hybrid", "fresh pineapple sugar apple", "fresh premium custard", "ripe atemoya"]
444	atlantic jackknife	["bamboo clam atlantic", "ensis", "pod razor", "razor clam atlantic", "straight razor"]
445	au jus	["beef juice", "meat juice", "natural jus", "pan drippings", "roast jus"]
446	au jus mix	["beef au jus mix", "french dip mix", "gravy mix au jus", "jus packet", "roast beef seasoning"]
447	australian yogurt	["australian style yogurt", "creamy australian", "honey yogurt base", "unstrained thick yogurt", "whole milk greek"]
448	avocado oil	["cooking avocado oil", "high heat avocado", "pressed avocado", "refined avocado oil", "virgin avocado oil"]
449	ayran	["drinking yogurt", "liquid yogurt drink", "salted yogurt drink", "turkish ayran", "yogurt drink"]
450	baby bananas	["finger bananas", "ladyfinger bananas", "manzano bananas", "mini bananas", "nino bananas"]
451	baby bok choy	["baby chinese cabbage", "baby pak choi", "mini bok choy", "shanghai bok choy", "small bok choy"]
452	baby carrots	["baby carrot", "cocktail carrots", "mini carrots", "petit carrots", "snack carrots"]
453	baby corn	["baby corn cobs", "baby sweetcorn", "cornlettes", "mini corn", "young corn"]
454	baby lima beans	["butter beans baby", "dried baby lima", "petite lima beans", "sieva beans", "small lima beans"]
455	baby octopus fresh	["cocktail octopus", "grilling octopus", "mini octopus", "small octopus fresh", "young octopus"]
456	baby spinach	["baby spinach leaves", "mini spinach", "salad spinach", "tender spinach", "young spinach"]
457	baby vegetables	["micro vegetables", "miniature vegetables", "petite vegetables", "tiny vegetables", "young vegetables"]
459	bacon fat	["bacon drippings", "bacon grease", "pork fat bacon", "rendered bacon fat", "saved bacon fat"]
460	bagels	["bagel", "boiled bagels", "breakfast bagels", "ny bagels", "plain bagels"]
461	baharat	["arabian spice blend", "lebanese seven spice", "middle eastern baharat", "seven spice", "warm spice blend"]
462	baked beans	["beans in tomato sauce", "boston baked beans", "canned baked beans", "navy beans baked", "sweet baked beans"]
463	baker ammonia	["ammonium carbonate", "hartshorn", "sal volatile", "smelling salt baking", "traditional leavener"]
464	baking chocolate	["100% chocolate", "bakers chocolate", "bitter chocolate", "chocolate liquor", "unsweetened chocolate"]
3	baking powder	["baking agent", "baking powder aluminum free", "chemical leavener", "double acting baking powder", "leavening agent", "leavening powder", "raising powder"]
467	baklava	["greek baklava", "honey baklava", "middle eastern pastry", "phyllo nut pastry", "walnut baklava"]
468	balsamic vinaigrette	["balsamic dressing", "balsamic italian", "italian balsamic", "modena vinaigrette", "sweet balsamic"]
5	balsamic vinegar	["aceto balsamico", "aged balsamic", "balsamic", "balsamic reduction", "italian balsamic", "modena vinegar", "sweet vinegar"]
470	bambara beans	["african groundnut", "bambara groundnut", "earth peas", "ground beans", "jugo beans"]
6	bamboo shoots	["bamboo hearts", "bamboo sprouts", "bamboo tips", "fresh bamboo shoots", "pickled bamboo", "tender bamboo", "young bamboo"]
2	bacon	["bacon", "pork bacon", "streaky bacon", "breakfast bacon", "rashers", "american bacon", "back bacon"]
472	banana flower	["banana blossom", "banana heart", "plantain flower", "purple banana flower", "tropical flower"]
473	banana ketchup	["filipino ketchup", "jufran", "red banana sauce", "sweet banana sauce", "ufc banana ketchup"]
474	banana leaves	["banana leaf", "fresh banana leaves", "plantain leaves", "tropical leaves", "wrapping leaves"]
475	banana passion fruit	["curuba", "passiflora tripartita", "soft banana passion", "taxo", "tumbo"]
476	banana peppers	["banana chilies", "hungarian wax peppers", "sweet banana peppers", "yellow chile peppers", "yellow peppers hot"]
477	bananas	["banana", "cavendish bananas", "fresh bananas", "ripe bananas", "yellow bananas"]
478	barbecue sauce	["bbq sauce", "grilling sauce", "kansas city bbq", "smoky bbq", "sweet barbecue sauce"]
479	barberries	["barberry", "berberis", "jaundice berry", "persian barberries", "pipperidge bush"]
480	barhi dates	["caramel dates", "fresh barhi", "honey ball dates", "soft dates barhi", "yellow dates"]
481	barley	["hulled barley", "pearl barley", "pot barley", "scotch barley", "soup barley"]
482	barley malt syrup	["bagel syrup", "barley extract", "diastatic malt syrup", "malt extract", "malted barley syrup"]
483	barnacles	["goose barnacles", "gooseneck barnacles", "percebes", "pollicipes", "stalked barnacles"]
484	barramundi	["asian sea bass", "australian bass", "barra", "giant perch", "silver perch"]
485	bartlett pears	["bartlett", "butter pears", "summer pears", "williams pears", "yellow pears"]
486	baru nut	["baru seed", "barukas", "baruzeiro", "brazilian almond", "cerrado nut"]
487	basil oil	["holy basil oil", "italian basil oil", "ocimum oil", "pesto oil", "sweet basil oil"]
488	basmati rice	["aromatic rice", "fragrant rice", "himalayan rice", "indian rice", "long grain basmati"]
490	bay scallops	["calico scallops", "cape scallops", "small scallops", "sweet scallops", "tiny scallops"]
491	bbq rub	["barbecue dry rub", "bbq seasoning rub", "meat rub", "smoking rub", "texas bbq rub"]
492	bean sprouts	["chinese bean sprouts", "fresh bean sprouts", "mung bean sprouts", "soybean sprouts", "sprouted beans"]
493	bear meat	["black bear", "brown bear meat", "game bear", "ursus", "wild bear"]
494	beaufort	["beaufort aoc", "firm mountain cheese", "fondue cheese french", "french alpine cheese", "gruyere de beaufort"]
495	beech mushrooms	["brown beech", "clamshell mushroom", "hon shimeji", "shimeji", "white beech"]
496	beef bouillon	["beef base powder", "beef broth powder", "beef stock powder", "dehydrated beef", "instant beef stock"]
497	beef broth	["beef base liquid", "beef bouillon liquid", "beef stock", "low sodium beef broth", "meat broth"]
498	beef heart	["anticuchos meat", "beef offal heart", "heart meat", "organ heart", "ox heart"]
499	beef liver	["beef offal", "calves liver", "liver meat", "organ meat beef", "ox liver"]
500	beef shank	["cross cut shank", "marrow bones beef", "osso buco", "shin beef", "soup bones"]
501	beef tallow	["beef dripping", "beef grease", "cooking tallow", "rendered beef fat", "suet rendered"]
502	beef tenderloin	["beef fillet", "chateaubriand", "filet mignon", "tenderloin roast", "whole tenderloin"]
503	beef tongue	["beef offal tongue", "lengua", "ox tongue", "pickled tongue", "tongue meat"]
504	beefsteak tomatoes	["beef tomatoes", "beefsteak tomato", "large tomatoes", "sandwich tomatoes", "slicing tomatoes"]
505	beet greens	["beet leaves", "beet tops", "beetroot leaves", "red beet greens", "swiss chard beet"]
506	beets	["beet", "beetroot", "garden beets", "red beets", "table beets"]
507	berbere	["berbere powder", "doro wat spice", "east african blend", "ethiopian red spice", "ethiopian spice blend"]
508	bergamot oil	["aromatic citrus oil", "calabrian bergamot oil", "citrus bergamia", "earl grey oil", "italian bergamot"]
509	berries	["assorted berries", "berry medley", "berry mix", "fresh berries", "mixed berries"]
510	betel nut	["areca catechu", "areca nut", "betel palm seed", "pinang", "supari"]
511	bhutanese red rice	["himalayan red rice", "mountain red rice", "nutty red rice", "rosy rice", "short grain red"]
512	bing cherries	["bing", "black cherries sweet", "dark sweet cherries", "pacific cherries", "washington bing"]
513	biscuit mix	["all purpose baking mix", "baking mix", "bisquick", "pancake biscuit mix", "southern biscuit mix"]
514	biscuits	["baking powder biscuits", "buttermilk biscuits", "drop biscuits", "flaky biscuits", "southern biscuits"]
515	bison	["american buffalo", "bison steak", "buffalo meat", "ground bison", "plains bison"]
516	bitter melon	["balsam pear", "bitter cucumber", "bitter gourd", "chinese bitter melon", "karela"]
517	bittersweet chocolate	["70% cacao", "dark baking chocolate 60%", "european baking chocolate", "extra dark chocolate", "intense chocolate"]
518	black bean pasta	["alternative pasta black", "bean pasta black", "gluten free black bean", "high protein black bean", "pulse pasta black"]
519	black bean sauce	["asian black bean", "chinese black bean", "douchi sauce", "fermented black bean", "salted black beans"]
520	black bean sprouts	["black bean shoots", "black turtle sprouts", "germinated black beans", "mexican bean sprouts", "sprouted black beans"]
522	black cherry tomatoes	["black grape tomatoes", "chocolate cherry", "dark cherry tomatoes", "indigo cherry", "purple cherry"]
523	black cocoa powder	["charcoal cocoa", "extra dark dutched", "oreo cocoa", "super dark cocoa", "ultra-dutched cocoa"]
524	black cod	["black sablefish", "butterfish", "coalfish alternative", "sablefish", "skilfish"]
525	black currant seed oil	["blackcurrant oil", "cassis seed oil", "gla currant oil", "omega currant", "ribes oil"]
526	black currants	["blackcurrants", "cassis", "quinsy berries", "ribes nigrum", "squinancy berries"]
527	black eyed peas	["black-eyed peas", "cowpeas", "dried black eyed", "field peas", "southern peas"]
528	black gram	["black lentils", "split black gram", "urad dal", "vigna mungo", "whole black gram"]
529	black grapes	["black seedless", "concord grapes", "dark grapes", "midnight grapes", "purple grapes"]
530	black krim tomatoes	["black crimean", "chocolate tomatoes", "dark heirloom", "purple tomatoes", "russian black"]
531	black lentils	["beluga lentils", "black gram", "caviar lentils", "tiny black lentils", "urad dal whole"]
532	black mission figs	["black figs", "california figs", "dark figs", "mission figs", "purple figs"]
533	black mustard seeds	["brassica nigra", "brown mustard seeds", "hot mustard seeds", "indian mustard seeds", "rai seeds"]
534	black olives	["california olives", "pitted black olives", "ripe olives", "sliced black olives", "whole black olives"]
535	black pepper	["fine black pepper", "ground black pepper", "pepper", "peppercorns ground", "table pepper"]
536	black pepper oil	["black gold oil", "ground pepper oil", "peppercorn oil", "piper oil", "spicy pepper oil"]
537	black peppercorns	["malabar pepper", "pepper berries", "tellicherry peppercorns", "whole black pepper", "whole pepper"]
538	black plums	["black beauty", "black plum", "damson plums", "friar plums", "purple plums dark"]
539	black quinoa	["black grain", "dark quinoa", "dark seed quinoa", "earthier quinoa", "midnight quinoa"]
540	black radish	["black spanish radish", "noir gros", "round black radish", "spanish radish", "winter radish"]
541	black rice	["chinese black rice", "dark rice", "forbidden rice", "purple rice", "venere rice"]
542	black rice forbidden	["antioxidant rice", "chinese forbidden", "emperor rice premium", "purple forbidden rice", "rare black grain"]
543	black sapote	["black persimmon", "chocolate pudding fruit", "diospyros digyna", "mexican persimmon", "zapote negro"]
544	black seed oil	["black caraway oil", "black cumin oil", "kalonji oil", "nigella oil", "onion seed oil"]
545	black sesame seeds	["asian black sesame", "black sesame", "dark sesame", "unhulled sesame seeds", "whole sesame seeds"]
546	black vinegar	["aged rice vinegar", "chinese black vinegar", "chinkiang vinegar", "dark rice vinegar", "zhenjiang vinegar"]
547	black walnuts	["american black walnuts", "heartnut", "native walnuts", "strong flavored walnuts", "wild walnuts"]
548	blackberries	["blackberry", "brambleberries", "cultivated blackberries", "fresh blackberries", "wild blackberries"]
549	blackcurrant oil	["black currant oil", "cassis seed oil", "gla oil currant", "omega currant oil", "ribes oil seed"]
550	blackstrap molasses	["dark blackstrap", "mineral rich molasses", "robust blackstrap", "third boiling molasses", "unsulphured blackstrap"]
551	blanched almonds	["blanched whole", "naked almonds", "peeled almonds", "skinless almonds", "white almonds"]
552	blood oranges	["blood orange", "moro oranges", "red oranges", "sanguinello", "tarocco oranges"]
553	blue cheese	["bleu cheese", "blue veined cheese", "crumbled blue", "moldy cheese", "strong blue"]
554	blue cheese dressing	["bleu cheese dressing", "blue cheese dip", "blue cheese sauce", "chunky blue cheese", "gorgonzola dressing"]
555	blue crab	["atlantic blue crab", "callinectes", "chesapeake blue crab", "maryland crab", "soft shell crab"]
556	blue mussels fresh	["atlantic blue mussels", "bay mussels", "common mussels", "mytilus edulis", "pacific blue mussels"]
557	blueberries	["blue berries", "blueberry", "cultivated blueberries", "fresh blueberries", "high bush blueberries"]
558	blueberry seed oil	["antioxidant berry oil", "blueberry oil", "omega blueberry", "vaccinium berry oil", "wild blueberry oil"]
559	bluefin tuna	["blue fin", "bluefin ahi", "giant tuna", "honmaguro", "maguro"]
560	bok choy	["bok choi", "chinese chard", "chinese mustard cabbage", "pak choi", "white cabbage"]
561	bolita beans	["bola beans", "dried bolita", "mexican pink beans", "rosita beans", "round beans"]
562	bomba rice	["calasparra", "paella rice", "short grain spanish", "spanish rice", "valencia rice"]
563	bone broth	["beef bone broth", "chicken bone broth", "collagen broth", "meat bone broth", "mineral broth"]
564	bone marrow	["beef marrow", "canoe bones", "center cut marrow", "marrow bones", "roasted marrow"]
565	bone-in chicken thighs	["chicken thigh quarters", "dark meat bone-in", "skin-on chicken thighs", "thigh portions", "thighs with bone"]
566	boneless skinless chicken breast	["fillet breast", "naked chicken breast", "plain chicken breast", "skinless boneless breast", "trimmed chicken breast"]
567	borage flowers	["bee bread flowers", "blue borage", "borago blooms", "cool tankard flowers", "starflower blooms"]
568	borage oil	["borage seed oil", "borago oil", "high gla oil", "omega oil borage", "starflower oil"]
569	borage seed oil	["borago seed oil", "gla source oil", "omega 6 borage", "skin oil borage", "starflower seed oil"]
570	bosc pears	["autumn pears", "beurre bosc", "bosc", "brown pears", "russet pears"]
571	bottle gourd	["calabash", "lauki", "long melon", "opo squash", "white flowered gourd"]
572	bouillon paste	["better than bouillon", "concentrated broth paste", "flavor paste", "soup base paste", "stock concentrate"]
573	boysenberries	["boysenberry", "hybrid berries", "loganberry", "marionberry", "rubus ursinus"]
574	braeburn apples	["braeburn", "crisp apples braeburn", "hillwell", "lady hamilton", "new zealand braeburn"]
575	braising greens	["cooking greens", "long cooking greens", "pot greens", "southern greens", "stewing greens"]
576	brandywine tomatoes	["beefsteak heirloom", "heirloom brandywine", "large pink tomatoes", "pink brandywine", "sudduth strain"]
577	bratwurst	["beer brats", "brats", "german sausage", "grilling sausage", "white sausage"]
578	brazil nut butter	["amazon nut butter", "brazil nut paste", "brazilian nut spread", "creamy brazil", "selenium butter"]
579	brazil nuts	["amazonian nuts", "castanha do para", "raw brazil nuts", "shelled brazil nuts", "whole brazil nuts"]
12	bread	["bread loaf", "loaf", "loaf bread", "sandwich bread", "sliced bread", "wheat bread", "white bread"]
13	bread crumbs	["breadcrumbs", "dried bread crumbs", "fresh bread crumbs", "italian bread crumbs", "panko", "plain bread crumbs", "seasoned bread crumbs"]
582	bread flour	["baker flour", "high gluten flour", "high protein flour", "strong flour", "yeast bread flour"]
583	breadfruit	["artocarpus altilis", "bread fruit", "rimas", "tropical breadfruit", "ulu"]
584	breadfruit fresh	["fresh artocarpus altilis", "fresh tropical breadfruit", "fresh ulu", "ripe breadfruit", "roasted breadfruit"]
585	breadsticks	["bread sticks", "crunchy breadsticks", "grissini", "italian breadsticks", "soft breadsticks"]
586	breakfast sausage	["breakfast links", "country sausage", "mild sausage", "morning sausage", "sausage patties"]
587	brewer yeast	["cheese substitute yeast", "inactive yeast", "nutritional yeast flakes", "savory yeast", "yellow yeast"]
588	brie	["bloomy rind", "brie cheese", "french brie", "soft brie", "triple cream brie"]
589	brioche	["brioche bread", "buttery bread", "egg bread", "french brioche", "rich bread"]
590	brisket	["bbq brisket", "beef brisket", "corned beef brisket", "flat cut brisket", "point cut brisket"]
591	broccoli florets	["broccoli", "broccoli crowns", "calabrese", "fresh broccoli", "green broccoli"]
592	broccoli sprouts	["baby broccoli sprouts", "broccoli sprouted", "microbroccoli", "sprouting broccoli seeds", "sulforaphane sprouts"]
80	parsley	["fresh parsley", "italian parsley", "flat-leaf parsley", "curly parsley"]
594	bronze cut pasta	["artisan pasta", "bronze die pasta", "rough pasta", "textured pasta", "traditional italian pasta"]
595	brown butter	["beurre noisette", "browned butter", "burnt butter", "caramelized butter", "hazelnut butter"]
596	brown lentils	["common lentils", "everyday lentils", "german lentils", "regular lentils", "spanish brown"]
597	brown rice	["hulled rice", "long grain brown", "natural rice", "unmilled rice", "whole grain brown rice"]
15	brown sugar	["dark brown sugar", "demerara", "golden brown sugar", "light brown sugar", "moist sugar", "muscovado", "packed brown sugar", "soft brown sugar"]
599	brown turkey figs	["aubique noire", "brown figs", "everbearing figs", "large figs", "turkey figs"]
600	brownie mix	["boxed brownie mix", "chewy brownie mix", "chocolate brownie mix", "fudge brownie mix", "ghirardelli style"]
81	pasta	["noodles", "spaghetti", "penne", "macaroni", "italian pasta"]
602	buckwheat	["buckwheat groats", "kasha", "pseudo-grain", "sarrasin", "soba grain"]
603	buckwheat flour	["dark buckwheat flour", "gluten free buckwheat", "graham flour alternative", "soba flour", "whole buckwheat flour"]
604	buckwheat honey	["dark honey", "mineral rich honey", "molasses-like honey", "robust honey", "strong honey"]
605	buddha hand	["buddha hand citron", "busshukan", "fingered citron", "fragrant citrus", "hand citrus"]
606	buffalo milk	["asian buffalo milk", "bubalus milk", "carabao milk", "mozzarella milk", "water buffalo milk"]
607	buffalo mozzarella fresh	["authentic buffalo mozz", "campania buffalo", "dop buffalo", "italian buffalo cheese", "mozzarella di bufala campana"]
608	buffalo sauce	["buffalo wing sauce", "cayenne butter sauce", "franks buffalo", "hot wing sauce", "spicy buffalo"]
609	buffalo yogurt	["asian buffalo yogurt", "buffalo milk yogurt", "italian buffalo yogurt", "thick buffalo yogurt", "water buffalo yogurt"]
610	buffaloberries	["buffalo berry", "russet buffaloberry", "shepherdia", "silver buffaloberry", "soapberry"]
611	bulgarian feta	["authentic feta", "balkan feta", "eastern feta", "sheep and goat feta", "sirene"]
612	bulgur wheat	["bulgar", "bulgur", "burghul", "cracked wheat", "groats"]
613	burdock root	["beggars buttons", "edible burdock", "gobo", "great burdock", "lappa root"]
614	burrata	["burrata cheese", "cream filled mozzarella", "fresh burrata", "italian burrata", "stracciatella"]
615	burro bananas	["blocky bananas", "chunky bananas", "cooking bananas burro", "orinoco bananas", "square bananas"]
616	butter flavored shortening	["baking butter shortening", "butter crisco", "butter flavored vegetable shortening", "golden shortening", "yellow shortening"]
617	butter lettuce	["bibb lettuce", "boston lettuce", "butter head", "butterhead lettuce", "soft lettuce"]
618	butter spray	["butter cooking spray", "butter flavored spray", "diet butter spray", "i cant believe spray", "zero calorie butter spray"]
619	buttermilk	["baking milk", "churned milk", "cultured buttermilk", "fermented milk", "sour milk"]
620	buttermilk powder	["cultured buttermilk powder", "dried buttermilk", "dry buttermilk", "powdered buttermilk", "sour milk powder"]
621	buttermilk solids	["buttermilk powder solids", "concentrated buttermilk", "cultured buttermilk solids", "dehydrated cultured milk", "dried buttermilk solids"]
622	butternut squash	["butternut", "butternut pumpkin", "gramma squash", "neck squash", "winter squash butternut"]
623	butternut squash noodles	["butternut spirals", "orange noodles", "spiralized squash", "squash noodles", "veggie noodles squash"]
624	butterscotch chips	["brown sugar chips", "butterscotch baking chips", "butterscotch morsels", "butterscotch pieces", "caramel chips alternative"]
625	cacao nibs	["chocolate nibs", "cocoa nibs", "crushed cacao beans", "raw cacao pieces", "roasted cacao"]
626	cacao powder	["ceremonial cacao", "cold processed cacao", "raw cacao powder", "superfood cacao", "unprocessed cocoa"]
627	caciocavallo	["aged pasta filata", "horse cheese", "southern cheese italy", "stretched curd italian", "tear drop cheese"]
628	cactus pear	["barbary fig", "indian fig", "opuntia", "prickly pear", "tuna fruit"]
630	cajun rub	["blackening rub", "cajun spice rub", "creole rub", "louisiana rub", "spicy cajun seasoning"]
631	cajun seasoning	["blackening spice", "cajun spice", "creole seasoning", "louisiana seasoning", "new orleans blend"]
632	cake flour	["fine flour", "low protein flour", "pastry flour soft", "soft flour", "tender flour"]
633	cake mix	["betty crocker style", "boxed cake mix", "chocolate cake mix", "white cake mix", "yellow cake mix"]
634	calabaza squash	["auyama", "calabaza pumpkin", "cuban squash", "tropical pumpkin", "west indian pumpkin"]
91	red onion	["red onions", "purple onion", "spanish onion"]
635	calamansi	["calamondin", "golden lime", "kalamansi", "musk lime", "philippine lime"]
636	calendula flowers	["calendula petals", "edible marigold", "healing flowers", "orange calendula", "pot marigold"]
637	calrose rice	["american sushi rice", "california rice", "japonica rice", "medium grain calrose", "short grain california"]
638	calypso beans	["black and white beans", "dried calypso", "orca beans", "panda beans", "yin yang beans"]
639	camel milk	["bedouin milk", "desert milk", "dromedary milk", "fresh camel milk", "raw camel milk"]
640	camellia oil	["asian cooking oil", "chinese olive oil", "tea oil", "tea seed oil", "tsubaki oil"]
641	camembert	["camembert cheese", "french camembert", "normandy camembert", "raw milk camembert", "soft camembert"]
642	campanelle	["ballerine", "bellflower pasta", "cone shaped pasta", "flower pasta", "gigli pasta"]
643	camu camu	["amazonian cherry", "cacari", "camu berry", "camucamu", "myrciaria dubia"]
644	canadian bacon	["back bacon", "irish bacon", "lean bacon", "loin bacon", "peameal bacon"]
645	canary melon	["bright yellow melon", "canary yellow melon", "juan canary", "spanish melon", "yellow honeydew"]
646	candied cherries	["fruitcake cherries", "glacé cherries", "green candied cherries", "maraschino cherries candied", "red candied cherries"]
647	candied citrus peel	["candied lemon peel", "candied orange peel", "crystallized peel", "glace citrus", "sugar peel"]
648	candied ginger	["candied ginger pieces", "crystallized ginger", "glace ginger", "preserved ginger", "sugar ginger"]
649	candied nuts	["caramelized nuts", "glazed nuts", "honey roasted nuts", "praline nuts", "sugar coated nuts"]
650	candlenut	["aleurites", "indian walnut", "kemiri", "kukui nut", "varnish tree nut"]
651	candy melts	["almond bark alternative", "candy coating", "colored melts", "confectionery coating", "melting wafers"]
652	cane syrup	["louisiana cane syrup", "pure cane syrup", "ribbon cane syrup", "southern cane syrup", "sugar cane syrup"]
653	cannellini beans	["dried cannellini", "fazolia beans", "italian white beans", "white cannellini", "white kidney beans"]
654	cannelloni	["crepes alternative", "italian tubes", "large pasta tubes", "rolled pasta", "stuffed tubes"]
655	canola oil	["canadian oil", "cooking canola", "low erucic oil", "neutral canola", "rapeseed oil"]
656	cantal	["aged cantal", "auvergne cheese", "firm french cheese", "fourme de cantal", "french cheddar"]
657	cantaloupe	["muskmelon", "netted melon", "orange melon", "rockmelon", "sweet melon"]
658	cape gooseberries	["golden berries", "ground cherries", "inca berries", "peruvian groundcherry", "physalis"]
659	cape gooseberries fresh	["fresh golden berries", "fresh ground cherries", "fresh inca berries", "fresh peruvian", "fresh physalis"]
660	caper berries	["caperberries", "large capers", "mediterranean capers", "stem capers", "whole capers"]
19	capers	["brined capers", "caper berries", "caper berries small", "italian capers", "nonpareil capers", "pickled capers", "salted capers"]
662	cara cara oranges	["cara cara", "pink navel", "pink oranges", "red flesh orange", "venezuelan oranges"]
663	caramel	["butterscotch alternative", "caramel sauce", "caramel syrup", "dulce de leche alternative", "liquid caramel"]
664	caramel bits	["baking caramels", "caramel pieces", "chewy caramel pieces", "kraft caramel bits", "soft caramel bits"]
665	caraway seeds	["caraway spice", "kummel", "meridian fennel", "persian cumin", "siya jeera"]
666	cardamom oil	["aromatic cardamom", "elaichi oil", "elettaria oil", "green cardamom oil", "indian cardamom oil"]
667	cardamom pods	["cardamom seeds", "cardamom whole", "elaichi", "green cardamom", "true cardamom"]
668	caribou	["arctic caribou", "rangifer", "reindeer meat", "tundra caribou", "wild caribou"]
669	carnaroli rice	["gourmet arborio", "italian carnaroli", "king of rice", "risotto rice premium", "superfino rice"]
670	carolina gold rice	["african rice american", "golden long grain", "heirloom rice", "heritage carolina", "plantation rice"]
671	carolina reaper	["carolina reaper chili", "hp22b", "reaper pepper", "smokin eds reaper", "worlds hottest chili"]
672	carrot seed oil	["carrot root oil", "daucus oil", "orange seed oil", "queen annes lace oil", "wild carrot oil"]
95	saffron	["saffron threads", "spanish saffron", "iranian saffron"]
674	casaba melon	["casaba", "golden casaba", "winter melon casaba", "wrinkled melon", "yellow casaba"]
675	cascabel peppers	["bell pepper dried", "bola chile", "cascabel chiles", "chile cascabel", "rattle chile"]
676	casein	["casein powder", "cheese protein", "milk casein", "milk protein", "protein casein"]
677	cashew butter	["creamy cashew butter", "raw cashew butter", "smooth cashew butter", "unsweetened cashew butter", "vegan cashew butter"]
678	cashew milk	["cashew beverage", "dairy free cashew", "nut milk cashew", "unsweetened cashew milk", "vanilla cashew milk"]
679	cashew pieces	["baking cashews", "broken cashews", "cashew bits", "cashew chips", "chopped cashews"]
680	cashew yogurt	["cashew milk yogurt", "dairy free cashew yogurt", "nut yogurt cashew", "plant cashew yogurt", "vegan cashew yogurt"]
681	cashews	["fancy cashews", "large cashews", "raw cashews", "roasted cashews", "whole cashews"]
682	cassava leaves	["manioc leaves", "pondu", "saka saka", "tropical greens", "yuca leaves"]
683	castelvetrano olives	["bright green olives", "buttery olives", "italian green olives", "nocellara olives", "sicilian olives"]
684	caster sugar	["baking sugar", "bar sugar", "castor sugar", "fine granulated sugar", "superfine sugar"]
685	catfish fillet	["catfish", "channel catfish", "farm raised catfish", "freshwater catfish", "southern catfish"]
686	caul fat	["lace fat", "membrane fat", "net fat", "pork caul", "pork omentum"]
687	cauliflower	["caulflower", "cauli", "cauliflour", "cauliflower head", "white cauliflower"]
688	cavatappi	["cellentani", "corkscrew macaroni", "double elbow", "spiral macaroni", "twisted macaroni"]
689	cayenne oil	["capsicum oil", "fiery cayenne", "heat oil", "hot pepper oil", "red chili oil spicy"]
690	cayenne pepper	["african pepper", "cayenne powder", "ground cayenne", "hot pepper powder", "red pepper powder"]
691	celery root	["celeriac", "celery bulb", "celery knob", "knob celery", "turnip rooted celery"]
692	celery salt	["bloody mary salt", "celery seasoned salt", "celery seed salt", "chicago dog salt", "vegetable salt"]
693	celery seeds	["apium seeds", "celery seed", "smallage seeds", "soup spice", "wild celery seeds"]
694	celery stalks	["celery", "celery ribs", "celery sticks", "green celery", "pascal celery"]
695	celtuce	["asparagus lettuce", "celery lettuce", "chinese lettuce", "stem lettuce", "wosun"]
696	challah	["braided bread", "ceremonial bread", "challah bread", "jewish egg bread", "sabbath bread"]
697	chamomile flowers	["calming flowers", "dried chamomile", "german chamomile", "matricaria", "roman chamomile"]
698	champagne grapes	["black corinth", "champagne grape", "miniature grapes", "tiny grapes", "zante currants"]
699	champagne vinegar	["delicate vinegar", "french champagne vinegar", "luxury vinegar", "sparkling wine vinegar", "white champagne vinegar"]
700	chana dal	["baby chickpeas", "bengal gram split", "split chickpeas", "split desi chickpeas", "yellow split chickpeas"]
701	chana masala	["channa masala", "chickpea curry", "chole", "indian chickpea", "spiced chickpeas"]
702	chanterelle mushrooms	["chanterelles", "egg mushroom", "girolle", "golden chanterelles", "pfifferling"]
703	charentais melon	["european cantaloupe", "french cantaloupe", "orange fleshed melon", "provence melon", "sweet charentais"]
704	chayote squash	["chayote", "cho-cho", "christophene", "mirliton", "vegetable pear"]
705	cheddar cheese	["cheddar", "mild cheddar", "orange cheddar", "sharp cheddar", "yellow cheddar"]
706	cheese curds	["cheddar curds", "day old cheddar", "fresh cheese curds", "poutine cheese", "squeaky cheese"]
707	cheese spread	["cheese whiz alternative", "cream cheese spread", "soft spread cheese", "spreadable cheese processed", "squeeze cheese"]
708	cheese wax	["black cheese wax", "cheese sealing wax", "coating wax", "paraffin cheese", "red cheese wax"]
709	cherimoya	["annona cherimola", "chirimoya", "custard apple", "sherbet fruit", "sugar apple"]
710	cherimoya fresh	["fresh annona cherimola", "fresh chirimoya", "fresh custard apple", "fresh sherbet fruit", "ripe cherimoya"]
711	cherokee purple	["dusky rose tomatoes", "pink purple tomatoes", "purple heirloom", "rich purple tomatoes", "tennessee heirloom"]
712	cherries	["cherry", "fresh cherries", "sweet cherries", "tree cherries", "whole cherries"]
713	cherry kernel oil	["cherry pit oil", "cherry seed oil", "prunus cerasus", "sour cherry oil", "stone fruit oil"]
714	cherry tomatoes	["cherry tomato", "cocktail tomatoes", "grape tomatoes", "snacking tomatoes", "sweet tomatoes"]
715	chestnut flour	["chestnut meal", "gluten free chestnut", "ground chestnuts", "italian chestnut flour", "sweet chestnut flour"]
716	chia seed oil	["chia oil", "cold pressed chia", "omega chia oil", "salvia hispanica oil", "superfood oil"]
717	chia seeds	["black chia seeds", "mexican chia", "salvia hispanica", "white chia seeds", "whole chia seeds"]
718	chicken bouillon	["chicken base powder", "chicken broth powder", "chicken stock powder", "dehydrated chicken", "instant chicken stock"]
24	chicken breast	["boneless chicken breast", "chicken breast fillet", "chicken breasts", "chicken cutlets", "skinless chicken breast", "white meat chicken"]
720	chicken broth	["chicken base liquid", "chicken bouillon liquid", "chicken stock", "low sodium chicken broth", "poultry broth"]
721	chicken drumsticks	["chicken leg quarters", "chicken legs", "drumstick", "leg pieces", "whole drumsticks"]
722	chicken fat	["cooking chicken fat", "jewish chicken fat", "poultry fat", "rendered chicken fat", "schmaltz"]
723	chicken leg quarters	["chicken hindquarter", "combo leg", "leg quarter", "quarter chicken leg", "thigh and drumstick"]
724	chicken rub	["bbq chicken rub", "chicken seasoning rub", "grilling chicken seasoning", "herb chicken rub", "poultry rub"]
725	chicken tenders	["breast tenderloins", "chicken fingers", "chicken strips", "chicken tenderloin", "tender pieces"]
726	chicken thighs	["bone-in chicken thighs", "chicken leg meat", "chicken thigh", "dark meat chicken", "skinless chicken thighs"]
727	chicken wings	["buffalo wings", "chicken wing", "party wings", "whole wings", "wingettes and drumettes"]
728	chickpea flour	["besan", "chana flour", "garbanzo bean flour", "garbanzo flour", "gram flour"]
729	chickpea pasta	["bean pasta chickpea", "gluten free chickpea", "high protein pasta", "legume pasta", "pulse pasta"]
730	chickpea sprouts	["chana sprouts", "garbanzo sprouts", "germinated garbanzo", "live chickpea sprouts", "sprouted chickpeas"]
732	chihuahua cheese	["melting cheese chihuahua", "mennonite cheese", "mexican cheddar", "mexican melter", "queso menonita"]
733	chilean sea bass	["antarctic toothfish", "chilean bass", "patagonian toothfish", "sea bass premium", "white seabass"]
734	chili beans	["beans in chili sauce", "canned chili beans", "kidney chili", "pinto chili", "seasoned beans"]
735	chili garlic sauce	["asian chili garlic", "garlic chili sauce", "huy fong chili garlic", "rooster garlic sauce", "sambal garlic"]
736	chili oil	["chile oil", "hot oil", "red chili oil", "sichuan chili oil", "spicy oil"]
737	chili paste	["asian chili paste", "chili sauce paste", "chinese chili paste", "hot pepper paste", "red chili paste"]
738	chili powder	["chile powder blend", "chilli powder", "ground chiles", "mexican chili powder", "red chili powder"]
739	chili seasoning	["chili con carne seasoning", "chili powder blend", "chili spice mix", "mild chili mix", "texas chili blend"]
740	chili seasoning mix	["chili packet", "chili spice packet", "instant chili mix", "mccormick chili mix", "texas chili seasoning"]
741	chimichurri	["argentinian herb sauce", "green chimichurri", "parsley sauce", "south american chimichurri", "steak sauce green"]
742	chinese eggplant	["asian purple eggplant", "chinese aubergine", "chinese brinjal", "long purple eggplant", "oriental eggplant chinese"]
743	chinese five spice	["5 spice", "asian five spice", "chinese five spice powder", "five spice powder", "wu xiang fen"]
744	chinese water lotus	["indian lotus root", "lotus stem", "nelumbo stem", "rhizome lotus", "sacred lotus stem"]
745	chioggia beets	["bulls eye beets", "candy cane beets", "candy stripe beets", "italian beetroot", "striped beets"]
746	chipotle in adobo	["adobo peppers", "canned chipotles", "chipotles in adobo sauce", "mexican chipotle", "smoked jalapenos in sauce"]
747	chipotle mayo	["chipotle aioli", "hot mayonnaise", "mexican mayo", "smoky mayo", "spicy mayo"]
748	chipotle oil	["bbq pepper oil", "chipotle infused", "mexican smoked oil", "smoked jalapeño oil", "smoky pepper oil"]
749	chipotle peppers	["chile chipotle", "chipotle chiles", "dried smoked peppers", "morita peppers", "smoked jalapenos"]
750	chlorella	["chlorella powder", "freshwater algae", "green algae", "micro algae", "superfood chlorella"]
751	chocolate bars	["baking chocolate bar", "chocolate block", "dark chocolate bar", "eating chocolate", "milk chocolate bar"]
26	chocolate chips	["baking chips", "chocolate morsels", "chocolate pieces", "dark chocolate chips", "mini chips", "semi-sweet chocolate chips"]
753	chocolate chunks	["baking chunks", "chocolate pieces large", "chunky chocolate", "hand chopped chocolate", "irregular chocolate"]
754	chokeberries	["aronia", "aronia melanocarpa", "black chokeberry", "choke berry", "superfruit aronia"]
755	cholula hot sauce	["chili pepper sauce", "cholula brand", "mexican hot sauce", "mexican pepper sauce", "tangy hot sauce"]
756	chorizo	["fresh chorizo", "mexican chorizo", "paprika sausage", "spanish chorizo", "spicy sausage"]
757	chow mein noodles	["crispy noodles", "crunchy chinese noodles", "fried noodles", "hong kong noodles", "stir fry crispy"]
758	christmas lima beans	["calico beans", "chestnut lima", "dried christmas", "large lima speckled", "speckled lima"]
759	chrysanthemum greens	["crown daisy", "edible chrysanthemum", "garland chrysanthemum", "shungiku", "tong ho"]
760	chuck roast	["arm roast", "blade roast", "chuck beef", "pot roast", "shoulder roast"]
761	chutney	["fruit chutney", "indian chutney", "mango chutney", "spicy chutney", "sweet chutney"]
762	ciabatta	["artisan ciabatta", "ciabatta bread", "holey italian bread", "italian slipper bread", "rustic italian bread"]
764	cinnamon chips	["cinnamon baking chips", "cinnamon flavored chips", "cinnamon morsels", "hershey cinnamon", "spice chips"]
765	cinnamon oil	["cassia oil culinary", "ceylon cinnamon oil", "dalchini oil", "spice oil cinnamon", "sweet cinnamon oil"]
766	cinnamon rolls	["cinnamon buns", "frosted cinnamon rolls", "morning rolls", "sticky buns", "sweet rolls"]
767	cinnamon sticks	["cassia bark", "ceylon sticks", "cinnamon quills", "mexican cinnamon", "true cinnamon"]
768	citric acid	["acidifier", "lemon salt", "preservative citric", "sour salt", "souring agent"]
769	citron	["cedrat", "citrus medica", "etrog", "mediterranean citron", "thick peel citrus"]
770	clabber	["raw milk cultured", "soured milk natural", "thick sour milk", "traditional clabber", "unpasteurized fermented"]
771	clams	["cherrystone clams", "fresh clams", "hard shell clams", "littleneck clams", "quahog"]
772	clams canned	["chopped clams canned", "clam meat canned", "minced clams", "ocean clams", "whole baby clams"]
773	clarified butter	["anhydrous milk fat", "butter oil", "drawn butter", "liquid butter", "pure butter fat"]
774	clementines	["algerian tangerines", "clementine", "easy peelers", "moroccan clementines", "seedless clementines"]
775	clotted cream	["clouted cream", "cornish cream", "devonshire cream", "double devon", "scalded cream"]
776	cloudberries	["averin", "bakeapple", "cloudberry", "evron", "knotberry"]
777	clove oil	["aromatic clove", "dental clove oil", "eugenia oil", "laung oil", "warm spice oil"]
778	clover honey	["american honey", "light honey", "mild honey", "sweet clover honey", "white honey"]
30	cloves	["clove buds", "clove powder", "eugenia", "ground cloves", "laung", "nail spice", "whole cloves"]
780	club crackers	["buttery oval crackers", "keebler club", "oval crackers", "salted crackers", "snack club crackers"]
781	cockle meat	["boiled cockles", "cockle flesh", "fresh cockles", "heart shaped clams", "pickled cockles"]
782	cockles	["ark cockles", "blood cockles", "cerastoderma", "european cockles", "heart cockles"]
783	cocktail sauce	["ketchup horseradish sauce", "prawn cocktail sauce", "red seafood sauce", "seafood sauce cocktail", "shrimp sauce"]
895	dashi	["bonito stock", "fish dashi", "instant dashi", "japanese stock", "kombu dashi"]
784	cocoa butter	["cacao butter", "cocoa fat", "theobroma oil", "vegetable fat cocoa", "white chocolate fat"]
785	cocoa nibs	["cacao nibs", "chocolate nibs", "crushed cacao", "raw cacao nibs", "roasted cocoa"]
787	coconut aminos	["amino sauce", "coconut soy sauce", "liquid coconut aminos", "paleo soy sauce", "soy free soy sauce"]
788	coconut butter	["coconut cream concentrate", "coconut manna", "creamed coconut", "pureed coconut", "whole coconut butter"]
789	coconut chips	["baked coconut chips", "coconut flakes large", "crispy coconut", "crunchy coconut", "toasted coconut chips"]
790	coconut chutney	["fresh coconut chutney", "kerala chutney", "south indian chutney", "thengai chutney", "white chutney"]
791	coconut cream	["coconut cream canned", "coconut milk fat", "cream of coconut alternative", "heavy coconut cream", "thick coconut milk"]
792	coconut flakes	["coconut chips", "coconut ribbons", "large coconut flakes", "toasted coconut flakes", "wide coconut"]
793	coconut flour	["coconut powder", "defatted coconut flour", "ground coconut", "low carb flour", "paleo flour"]
32	coconut milk	["canned coconut milk", "coconut beverage", "coconut cream", "coconut cream alternative", "full fat coconut milk", "thai coconut milk", "unsweetened coconut milk"]
795	coconut oil	["coconut cooking oil", "copra oil", "refined coconut oil", "tropical oil", "virgin coconut oil"]
796	coconut oil spray	["baking coconut spray", "coconut cooking spray", "coconut pam", "refined coconut spray", "tropical oil spray"]
797	coconut shreds	["baking coconut fine", "coconut threads", "dessicated coconut fine", "fine coconut", "powdered coconut"]
798	coconut sugar	["coco sugar", "coconut palm sugar", "low glycemic sugar", "palm sugar coconut", "unrefined coconut sugar"]
799	coconut vinegar	["asian coconut vinegar", "filipino vinegar", "palm vinegar", "sukang tuba", "tropical vinegar"]
800	coconut yogurt	["coco yogurt", "coconut milk yogurt", "dairy free yogurt coconut", "plant coconut yogurt", "vegan coconut yogurt"]
801	coconuts	["brown coconut", "coconut", "fresh coconut", "mature coconut", "whole coconut"]
802	cod fillet	["atlantic cod", "cod", "codfish", "pacific cod", "true cod"]
803	cod liver oil	["fish liver oil", "medicinal fish oil", "norwegian cod oil", "omega cod oil", "vitamin oil"]
804	coffee	["brewed coffee", "coffee beans", "ground coffee", "instant coffee alternative", "whole bean coffee"]
805	coho salmon	["coho", "medium salmon", "pacific salmon", "silver salmon", "wild coho"]
806	colby cheese	["american colby", "colby", "colby longhorn", "longhorn cheese", "mild colby"]
807	colby jack	["cojack", "colby monterey jack", "marble jack", "marbled cheese", "mixed jack"]
808	coleslaw mix	["cabbage slaw", "coleslaw vegetables", "pre-shredded slaw", "shredded cabbage", "slaw blend"]
809	collard greens	["colewort", "collard", "collards", "non-heading cabbage", "tree cabbage"]
810	comice pears	["butter pears comice", "christmas pears", "comice", "doyenne du comice", "premium pears"]
811	compound butter	["flavored butter", "garlic butter", "herb butter", "maitre d butter", "restaurant butter"]
111	tomatoes	["tomatoes", "tomato", "fresh tomatoes", "plum tomatoes", "roma tomatoes", "slicing tomatoes", "red tomatoes"]
813	conch	["caribbean conch", "lambi", "queen conch", "sea snail", "strombus"]
814	condensed milk	["canned milk sweetened", "concentrated milk", "eagle brand", "sweetened condensed milk", "thick sweet milk"]
815	cookie crumbs	["baking cookie crumbs", "cookie dust", "crushed cookies", "oreo crumbs alternative", "pie crust cookies"]
816	cookie mix	["baking cookie mix", "brownie cookie mix", "chocolate chip cookie mix", "instant cookie mix", "sugar cookie mix"]
1	almonds	["almonds", "prunus dulcis", "almond nuts", "california almonds", "natural almonds", "raw almonds", "shelled almonds"]
818	coriander oil	["asian coriander", "cilantro seed oil", "coriandrum oil", "dhania oil", "sweet coriander oil"]
114	tzatziki	["tzatziki sauce", "greek yogurt sauce", "cucumber yogurt sauce"]
820	corn kernels	["corn", "fresh corn", "maize kernels", "sweet corn kernels", "yellow corn"]
821	corn oil	["cooking corn oil", "golden corn oil", "maize oil", "refined corn oil", "vegetable corn oil"]
822	corn on the cob	["corn cob", "ears of corn", "fresh corn cob", "sweet corn", "whole corn"]
823	corn relish	["corn salsa", "midwest relish", "pepper corn relish", "sweet corn relish", "vegetable relish"]
824	corn salad	["field salad", "lambs lettuce", "mache", "rapunzel", "valerianella"]
825	corn syrup	["candy making syrup", "clear corn syrup", "glucose syrup", "karo syrup", "light corn syrup"]
826	corn tortillas	["authentic corn tortillas", "mexican corn tortillas", "taco tortillas corn", "white corn tortillas", "yellow corn tortillas"]
827	cornbread	["corn bread", "jiffy cornbread", "skillet cornbread", "southern cornbread", "sweet cornbread"]
828	cornbread mix	["corn bread mix", "instant cornbread", "jiffy corn muffin mix", "southern cornbread mix", "sweet cornbread mix"]
829	cornish game hen	["baby chicken", "cornish hen", "game hen", "poussin", "rock cornish"]
830	cornmeal	["coarse cornmeal", "corn meal", "polenta", "white cornmeal", "yellow cornmeal"]
831	cornstarch	["corn flour starch", "corn starch", "cornflour", "maize starch", "modified corn starch"]
833	cotija cheese	["aged mexican cheese", "crumbling cheese mexican", "hard cotija", "mexican parmesan", "salty mexican cheese"]
834	cottage cheese	["curd cheese", "farmers cheese loose", "large curd cottage", "pot cheese", "small curd cottage"]
835	cotton candy grapes	["candy grapes", "cotton candy grape", "flavored grapes", "novelty grapes", "sweet grapes"]
836	cottonseed oil	["cooking cottonseed", "gossypium oil", "partially hydrogenated cottonseed", "refined cottonseed", "southern oil"]
837	country style ribs	["blade end ribs", "boneless country ribs", "country ribs", "meaty ribs", "pork shoulder ribs"]
838	couscous	["israeli couscous alternative", "moroccan couscous", "north african pasta", "semolina couscous", "tiny pasta"]
839	couscous pasta	["moroccan pasta", "north african couscous", "quick pasta", "semolina balls", "tiny pasta balls"]
840	couverture chocolate	["coating chocolate", "high cocoa butter chocolate", "pastry chocolate", "professional chocolate", "tempering chocolate"]
841	crab meat	["crabmeat", "fresh crab", "jumbo lump crab", "lump crab", "picked crab"]
842	crab meat canned	["blue crab canned", "canned crabmeat", "dungeness canned", "jumbo lump canned", "lump crab canned"]
843	cracked freekeh	["broken freekeh", "coarse freekeh", "crushed freekeh", "green wheat cracked", "rubbed freekeh"]
844	crackers	["saltine crackers", "snack crackers", "soda crackers", "table crackers", "water crackers"]
845	cranberries	["american cranberry", "bog berries", "bounceberries", "cranberry", "fresh cranberries"]
846	cranberry beans	["borlotti beans", "dried cranberry", "roman beans", "rosecoco beans", "saluggia beans"]
847	cranberry sauce	["canned cranberry", "jellied cranberry sauce", "ocean spray cranberry", "thanksgiving cranberry", "whole berry cranberry"]
848	cranberry seed oil	["american cranberry oil", "bog berry oil", "cranberry oil", "omega cranberry", "vaccinium oil"]
849	crawfish	["crawdads", "crayfish", "freshwater lobster", "mudbugs", "yabbies"]
850	cream cheese	["bagel cheese", "block cream cheese", "fresh cream cheese", "soft cheese", "spreadable cream cheese"]
812	comté	["aged comte", "aoc comte", "comté", "french gruyere", "jura cheese"]
851	cream of coconut	["coco lopez", "coconut cream sweetened", "coconut dessert cream", "piña colada mix", "sweetened coconut cream"]
852	cream of tartar	["baking acid", "meringue stabilizer", "potassium bitartrate", "tartaric acid", "wine crystals"]
853	cream of wheat	["cream of wheat cereal", "farina", "hot wheat cereal", "semolina cereal", "wheat porridge"]
854	crema fresca	["central american cream", "fresh cream", "honduran cream", "salvadoran cream", "sweet crema"]
855	creme de cassis	["berry cream", "blackcurrant cream", "cassis liqueur base", "currant cream", "dessert cream blackcurrant"]
120	water	["h2o", "drinking water", "filtered water"]
857	cremini mushrooms	["baby bella", "baby portobello", "brown mushrooms", "cremini", "italian brown mushrooms"]
858	crenshaw melon	["casaba crenshaw", "cranshaw", "hybrid melon", "sweet crenshaw", "winter crenshaw"]
859	crepes	["delicate pancakes", "french crepes", "savory crepes", "sweet crepes", "thin pancakes"]
860	cricket flour	["acheta flour", "cricket powder", "ground crickets", "insect flour", "protein flour insect"]
861	croissants	["butter croissants", "crescent rolls", "croissant", "flaky croissants", "french croissants"]
862	crosnes	["chinese artichoke", "chorogi", "japanese artichoke", "knotroot", "stachys"]
34	croutons	["bread cubes", "caesar croutons", "garlic croutons", "herbed croutons", "salad croutons", "seasoned croutons", "toasted bread cubes"]
864	crowberries	["black crowberry", "crakeberry", "crowberry", "curlew berry", "empetrum"]
865	crunchy peanut butter	["chunky peanut butter", "extra crunchy", "peanut butter with pieces", "super chunk", "textured peanut butter"]
866	crushed red pepper	["chile flakes", "crushed chili", "hot pepper flakes", "pizza pepper", "red pepper flakes"]
867	crushed tomatoes	["chunky tomato sauce", "coarsely ground tomatoes", "crushed tomato sauce", "ground tomatoes", "italian crushed tomatoes"]
868	crustacean oil	["bisque oil", "lobster oil", "seafood oil", "shellfish oil", "shrimp oil"]
869	crystal hot sauce	["cajun hot sauce", "louisiana crystal", "mild louisiana sauce", "southern hot sauce", "vinegar hot sauce"]
870	cubanelle peppers	["cuban peppers", "green frying peppers", "italian frying peppers", "mediterranean peppers", "sweet italian peppers"]
871	cubeb pepper	["cubeb berries", "java pepper", "kabab chini", "piper cubeba", "tailed pepper"]
872	cucumber seed oil	["cold pressed cucumber", "cucumber kernel oil", "cucumis oil", "green seed oil", "salad oil cucumber"]
873	cucumbers	["cucumber", "fresh cucumber", "garden cucumber", "green cucumber", "slicing cucumber"]
874	cultured butter	["cultured cream butter", "european butter", "european style butter", "fermented butter", "slow churned butter"]
875	cumin	["comino", "cumin powder", "cummin", "ground cumin", "jeera"]
876	cumin oil	["aromatic cumin oil", "cuminum oil", "earthy cumin oil", "jeera oil", "middle eastern cumin"]
877	cumin seeds	["caraway alternative", "cumin whole", "cumino", "jeera seeds", "whole cumin"]
878	cupuacu	["amazon cupuacu", "brazilian cacao", "cupuassu", "cupuazu", "theobroma grandiflorum"]
879	cupuacu fresh	["fresh amazon cupuacu", "fresh brazilian cacao", "fresh cupuassu", "fresh theobroma grandiflorum", "ripe cupuacu"]
881	curry leaves	["curry leaf", "indian bay leaf", "kadi patta", "murraya", "sweet neem"]
882	curry paste	["green curry paste", "indian curry paste", "red curry paste", "thai curry paste", "yellow curry paste"]
883	curry powder	["curry masala", "curry spice blend", "indian curry mix", "madras curry powder", "mild curry powder"]
884	cuttlebone	["calcium source", "cuttlefish internal shell", "mineral block", "sepia bone", "sepion"]
885	cuttlefish	["cuttle", "fresh cuttlefish", "inkfish", "sepia", "whole cuttlefish"]
886	daikon radish	["chinese radish", "japanese radish", "mooli", "oriental radish", "white radish"]
887	dal	["daal", "dhal", "indian lentil stew", "lentil curry", "spiced lentils"]
888	dandelion greens	["cultivated dandelion", "dandelion leaves", "lion tooth", "pissenlit", "wild dandelion"]
889	danish blue	["blue castello", "creamy blue cheese", "danablu", "danish blue cheese", "mild blue danish"]
890	danish pastry	["bakery danish", "cheese danish", "danish", "fruit danish", "sweet danish"]
891	dark brown sugar	["dark soft sugar", "deep brown sugar", "molasses sugar dark", "muscovado light", "old fashioned brown"]
892	dark chocolate chips	["60% chocolate chips", "bittersweet chips", "extra dark chips", "intense chocolate chips", "premium dark chips"]
893	dark corn syrup	["brown corn syrup", "caramel corn syrup", "karo dark", "molasses corn syrup", "refiner syrup"]
894	dark soy sauce	["aged soy sauce", "black soy sauce", "caramel soy", "chinese dark soy", "thick soy sauce"]
896	date sugar	["dried date sugar", "ground dates", "natural date sweetener", "unrefined date sugar", "whole date sugar"]
897	date syrup	["concentrated dates", "date honey", "date molasses", "middle eastern syrup", "silan"]
898	dates	["date fruit", "deglet noor", "fresh dates", "medjool dates", "palm dates"]
899	datil pepper	["caribbean datil", "florida datil", "hot yellow pepper", "st augustine pepper", "yellow scorpion"]
900	daylily buds	["dried lily buds", "golden needles", "gum jum", "hemerocallis", "tiger lily buds"]
901	deglet noor dates	["baking dates", "deglet noor", "regular dates", "semi dry dates", "tunisian dates"]
902	delicata squash	["bohemian squash", "delicata", "peanut squash", "sweet potato squash", "winter squash delicata"]
903	della rice	["american basmati", "aromatic american rice", "della brand", "texas rice", "texmati rice"]
904	demerara sugar	["coarse brown sugar", "coffee sugar", "golden crystals", "raw cane sugar", "turbinado sugar"]
905	demi glace	["brown sauce", "concentrated stock", "demi-glace", "espagnole reduction", "french brown sauce"]
906	devonshire cream	["clotted cream devon", "devon cream", "english clotted cream", "scone cream", "tea cream"]
907	dewberries	["dewberry", "ground berry", "mayes dewberry", "running blackberry", "wild dewberry"]
908	diastatic malt powder	["active malt", "bread improver malt", "diastatic malt", "enzyme malt", "malted milk powder alternative"]
909	diced tomatoes	["chopped tomatoes", "cut tomatoes", "fire roasted diced", "italian diced tomatoes", "petite diced tomatoes"]
910	dijon mustard	["creamy mustard", "french mustard", "grey poupon style", "smooth mustard", "wine mustard"]
911	dill havarti	["dill cheese", "flavored havarti", "garden havarti", "herb havarti", "herbed danish cheese"]
912	dill oil	["anethum oil", "dill weed oil", "fresh dill oil", "pickle herb oil", "scandinavian dill oil"]
913	dill pickle relish	["dill relish", "kosher relish", "sour pickle relish", "tart relish", "traditional relish"]
914	dill seeds	["american dill seeds", "anethum seeds", "dill spice", "dill weed seeds", "dillweed seeds"]
915	dinner rolls	["bread rolls", "cloverleaf rolls", "parker house rolls", "soft rolls", "yeast rolls"]
916	ditalini	["little thimbles", "salad macaroni", "soup pasta small", "tiny tubes", "tubetti"]
917	domsiah rice	["basmati persian", "domesiah rice", "iranian rice", "persian rice", "tarom rice"]
918	donkey milk	["ass milk", "donkey dairy", "equine milk donkey", "jenny milk", "moke milk"]
919	donut peaches	["chinese flat peach", "flat peaches", "peen tao", "saturn peaches", "saucer peaches"]
920	donuts	["cake donuts", "doughnuts", "fried donuts", "glazed donuts", "yeast donuts"]
921	dosa mix	["crepe mix", "fermented dosa", "instant dosa mix", "rice lentil crepe", "south indian dosa"]
922	double cream	["48% cream", "british double cream", "extra thick cream", "pouring cream double", "uk heavy cream"]
923	dough conditioner	["bread improver", "bread softener", "commercial improver", "dough enhancer", "vital wheat gluten blend"]
924	dragees	["decorative balls", "edible pearls", "gold balls", "metallic sprinkles", "silver balls"]
925	dragon fruit	["cactus fruit", "night blooming cereus", "pitahaya", "pitaya", "strawberry pear"]
926	dragon fruit yellow	["ecuadorian pitaya fresh", "golden dragon fresh", "sweet yellow fresh", "yellow flesh dragon", "yellow pitaya fresh"]
927	dragon tongue beans	["dutch yellow", "fresh dragon tongue", "pole beans fresh", "snap beans purple", "wax beans purple"]
928	dried apricots	["california apricots dried", "dried apricot halves", "dried turkish apricots", "orange dried fruit", "sulfured apricots"]
929	dried basil	["basil dried", "basil flakes", "crushed basil", "dehydrated basil", "dried sweet basil"]
930	dried blueberries	["blueberry dried fruit", "blueberry raisins", "dried blues", "dried sweet blueberries", "dried wild blueberries"]
931	dried cherries	["cherry raisins", "dried bing cherries", "dried montmorency", "dried sweet cherries", "dried tart cherries"]
932	dried chives	["chive bits", "chive flakes", "dehydrated chives", "dried chive", "freeze dried chives"]
933	dried cilantro	["cilantro dried", "cilantro flakes", "coriander leaves dried", "dehydrated cilantro", "dried coriander"]
934	dried cranberries	["craisins", "cranberry raisins", "dried sweetened cranberries", "ocean spray cranberries", "sweet dried cranberries"]
935	dried dates	["chopped dates", "date pieces", "dried deglet noor", "dried medjool", "pitted dates"]
936	dried dill	["dehydrated dill", "dill flakes", "dill weed dried", "dillweed dried", "dried dill weed"]
937	dried figs	["dried black figs", "dried calimyrna", "dried mission figs", "fig halves dried", "turkish figs dried"]
938	dried fruit	["assorted dried fruit", "baking fruit", "fruit medley dried", "mixed dried fruit", "trail mix fruit"]
939	dried marjoram	["dehydrated marjoram", "marjoram dried", "marjoram flakes", "marjoram leaves dried", "sweet marjoram dried"]
940	dried mint	["dehydrated mint", "dried mint leaves", "mint flakes", "peppermint dried", "spearmint dried"]
941	dried octopus	["dehydrated octopus", "dried tako", "preserved octopus", "pressed octopus", "snack octopus"]
942	dried oregano	["greek oregano dried", "mexican oregano", "oregano dried", "oregano leaves dried", "wild marjoram dried"]
943	dried parsley	["crushed parsley", "dehydrated parsley", "dried parsley flakes", "parsley dried", "parsley flakes"]
944	dried rosemary	["crushed rosemary", "dehydrated rosemary", "dried rosemary needles", "ground rosemary alternative", "rosemary dried"]
945	dried sage	["dehydrated sage", "dried sage leaves", "ground sage alternative", "rubbed sage", "sage dried"]
946	dried squid	["dried cuttlefish", "ika", "pressed squid", "shredded squid", "squid jerky"]
947	dried tarragon	["dehydrated tarragon", "estragon dried", "french tarragon dried", "tarragon dried", "tarragon leaves dried"]
948	dried thyme	["crushed thyme", "dehydrated thyme", "dried thyme leaves", "ground thyme alternative", "thyme dried"]
949	drinking yogurt	["drinkable yogurt liquid", "liquid yogurt", "smoothie yogurt", "yogurt beverage", "yogurt drink sweetened"]
950	dry roasted peanuts	["dry peanuts", "dry roasted unsalted", "no oil peanuts", "plain roasted peanuts", "unseasoned peanuts"]
951	duck breast	["boneless duck breast", "duck breast fillet", "magret", "muscovy breast", "pekin duck breast"]
952	duck fat	["confit fat", "cooking duck fat", "duck grease", "french duck fat", "rendered duck fat"]
953	duck legs	["confit duck legs", "duck drumsticks", "duck leg", "duck leg quarters", "duck thighs"]
954	dukkah	["duqqa", "egyptian nut spice", "middle eastern blend", "nut herb mix", "seed spice mix"]
955	dulce de leche	["cajeta", "caramelized milk", "confiture de lait", "milk caramel", "south american caramel"]
956	dulse	["atlantic dulse", "dried dulse", "irish dulse", "palmaria palmata", "red seaweed"]
957	dumpling wrappers	["asian dumpling wrappers", "chinese dumpling skins", "gyoza wrappers", "potsticker wrappers", "round dumpling wrappers"]
958	dungeness crab	["dungeness", "metacarcinus", "pacific crab", "san francisco crab", "west coast crab"]
959	durian	["civet fruit", "durio", "king of fruits", "thorny fruit", "tropical durian"]
960	dutch process cocoa	["alkalized cocoa", "dark cocoa powder", "dutched cocoa", "european cocoa", "processed cocoa"]
961	edam	["ball cheese", "dutch edam", "edam cheese", "mild edam", "red wax cheese"]
962	edamame	["edamame beans", "fresh soybeans", "green soybeans", "soybean pods", "vegetable soybeans"]
963	edamame pasta	["gluten free soybean", "green soybean pasta", "high protein edamame", "japanese pasta", "soybean pasta"]
964	edible flowers mixed	["assorted edible flowers", "culinary flowers", "flower medley", "garden flowers edible", "mixed petals"]
965	edible glitter	["baking glitter", "disco dust", "edible shimmer", "luster dust edible", "sparkle dust"]
966	egg noodles	["buttered noodles", "kluski noodles", "pasta egg noodles", "pennsylvania dutch noodles", "wide egg noodles"]
967	egg roll wrappers	["chinese egg roll wrappers", "egg roll skins", "lumpia wrappers", "spring roll wrappers large", "thick wonton wrappers"]
968	egg white powder	["albumin powder", "dehydrated egg white", "dried egg whites", "meringue powder alternative", "powdered whites"]
969	egg yolk powder	["dehydrated yolk", "dried egg yolks", "powdered yolks", "whole egg alternative", "yellow egg powder"]
40	feta cheese	["greek feta", "brined cheese", "crumbled feta", "feta", "greek feta", "sheep feta", "sheep's milk feta"]
971	einkorn	["ancient wheat", "original wheat", "primitive wheat", "single grain wheat", "triticum monococcum"]
972	elderberries	["black elderberries", "elder berries", "elderberry", "european elder", "sambucus"]
973	elderflowers	["elder blooms", "elder blossoms", "elderflower heads", "sambucus flowers", "white elderflowers"]
974	elephant garlic	["garlic elephant", "giant garlic", "great headed garlic", "large garlic", "russian garlic"]
975	elk meat	["elk steak", "game meat elk", "red meat elk", "wapiti", "wild elk"]
976	emmental	["emmentaler", "emmenthal", "hole cheese swiss", "mountain cheese", "swiss cheese authentic"]
977	emmer	["ancient wheat emmer", "biblican wheat", "farro medio", "hulled wheat ancient", "pharaoh wheat"]
978	emu meat	["australian emu", "emu fillet", "emu steak", "ratite emu", "red emu meat"]
979	enchilada sauce	["chile colorado", "enchilada roja", "mexican red sauce", "red chili sauce", "red enchilada sauce"]
980	endive	["belgian endive", "chicory", "french endive", "white endive", "witloof"]
981	english cucumbers	["burpless cucumbers", "european cucumbers", "greenhouse cucumbers", "hothouse cucumbers", "seedless cucumbers"]
982	english muffins	["breakfast muffins", "english muffin", "nooks and crannies", "sandwich muffins", "toasting muffins"]
983	english peas	["fresh peas", "garden peas", "green peas", "shelling peas", "sweet peas"]
984	enoki mushrooms	["enoki", "enokitake", "golden needle mushroom", "velvet foot", "winter mushroom"]
985	envy apples	["envy", "new zealand envy", "premium envy", "red envy", "scilate"]
986	epazote	["herba sancti", "jesuit tea", "mexican tea", "skunkweed", "wormseed"]
988	escargot	["burgundy snails", "french snails", "garden snails", "helix snails", "land snails"]
989	escarole	["batavian endive", "broad endive", "broad-leaved endive", "escarolle", "scarole"]
990	esrom	["danish port salut", "full fat esrom", "monastery cheese danish", "port du salut danish", "stinky danish cheese"]
991	evaporated milk	["canned milk", "carnation milk", "concentrated milk unsweetened", "evap milk", "unsweetened condensed milk"]
992	evening primrose oil	["epo oil", "gamma linolenic oil", "oenothera oil", "omega 6 oil", "primrose seed oil"]
993	extra firm tofu	["dense tofu", "high protein tofu", "pressed firm tofu", "super firm tofu", "very firm tofu"]
994	extra virgin olive oil	["cold pressed olive oil", "evoo", "first press olive oil", "premium olive oil", "virgin olive oil"]
995	fajita seasoning	["fajita spice mix", "grilling fajita seasoning", "mexican fajita seasoning", "southwest fajita blend", "tex mex fajita mix"]
996	fajita vegetables	["fajita mix", "mexican fajita blend", "pepper onion mix", "sizzling vegetables", "tex mex vegetables"]
997	falafel mix	["chickpea falafel mix", "dried falafel", "falafel powder", "fava falafel mix", "instant falafel"]
998	farfalle	["bow tie pasta", "bow ties", "bowtie", "butterfly pasta", "farfalle pasta"]
999	farmers cheese	["bakers cheese", "dry curd cheese", "pot cheese pressed", "pressed cottage cheese", "quark alternative"]
1000	farro	["ancient grain farro", "emmer wheat", "italian farro", "spelt alternative", "whole grain farro"]
1001	farro intero	["hulled farro", "intact farro", "integrale farro", "whole farro", "whole grain emmer"]
1002	farro perlato	["decorticato", "pearled farro", "processed farro", "quick farro", "semi pearled farro"]
1003	fava beans	["broad beans", "faba beans", "field beans", "horse beans", "windsor beans"]
1004	fava beans dried	["broad beans dried", "dried fava", "faba beans dried", "ful beans", "horse beans dried"]
1005	feijoa	["acca", "feijoas", "guavasteen", "new zealand feijoa", "pineapple guava"]
1006	fennel bulb	["anise bulb", "fennel", "finocchio", "florence fennel", "sweet fennel"]
1007	fennel oil	["anise flavor oil", "florence fennel oil", "foeniculum oil", "licorice fennel oil", "sweet fennel oil"]
1008	fennel seeds	["fennel spice", "finocchio seeds", "florence fennel seeds", "saunf", "sweet cumin"]
1009	fenugreek seeds	["fenugreek whole", "greek hay seeds", "kasuri methi seeds", "methi seeds", "trigonella"]
1010	fermented tofu	["chinese cheese", "fermented bean curd", "fu ru", "preserved tofu", "stinky tofu"]
1012	fettuccine	["fettuccini", "flat pasta wide", "little ribbons", "ribbon pasta", "wide noodles"]
1013	fig vinegar	["balsamic fig", "dessert vinegar", "fruit vinegar fig", "italian fig vinegar", "sweet fig vinegar"]
1014	figs	["black mission figs", "common figs", "fig", "fresh figs", "tree figs"]
1015	filmjolk	["nordic yogurt", "ropy milk", "scandinavian buttermilk", "scandinavian cultured milk", "swedish sour milk"]
987	époisses	["burgundy cheese", "marc washed", "pungent soft cheese", "stinky french cheese", "washed epoisses"]
1016	finger bananas	["baby finger bananas", "lady finger bananas short", "nino banana alternative", "petite bananas", "short sweet bananas"]
1017	finger limes	["australian finger limes", "bush limes", "caviar limes", "citrus caviar", "lime pearls"]
1018	finger millet	["african millet", "kurakkan", "ragi", "red millet", "wimbi"]
1019	fingerling potatoes	["baby fingerlings", "finger potatoes", "fingerling potato", "french fingerlings", "russian banana"]
1020	fire roasted tomatoes	["charred tomatoes", "flame roasted tomatoes", "grilled tomatoes", "roasted tomatoes canned", "smoky tomatoes"]
1021	firm tofu	["block tofu", "chinese tofu", "extra firm tofu", "pressed tofu", "solid tofu"]
1023	fish seasoning	["blackened fish seasoning", "cajun fish rub", "grilling fish spice", "lemon pepper fish", "seafood seasoning"]
1024	fish stock	["asian fish stock", "court bouillon", "fish broth", "fumet", "seafood stock"]
1025	flageolet beans	["chevrier beans", "french kidney beans", "green flageolet", "immature kidney", "pale green beans"]
1026	flank steak	["bavette", "beef flank", "jiffy steak", "london broil", "thin flank"]
1027	flax milk	["dairy free flax", "flaxseed milk", "linseed milk", "omega milk flax", "plant flax milk"]
1028	flax seeds	["brown flax seeds", "flaxseed", "golden flax seeds", "linseeds", "whole flax seeds"]
1029	flaxseed oil	["cold pressed flax", "flax oil", "linseed oil culinary", "linum oil", "omega 3 oil"]
1030	flounder	["flounder fillet", "fluke", "lemon sole", "summer flounder", "winter flounder"]
1031	flour tortillas	["burrito wraps", "fajita tortillas", "mexican flour tortillas", "soft flour tortillas", "wheat tortillas large"]
1032	focaccia	["dimpled bread", "focaccia bread", "herb focaccia", "italian flatbread", "olive oil bread"]
1033	fontina	["alpine fontina", "fontal", "fontina val d aosta", "italian fontina", "semi-soft fontina"]
1034	fontina val d aosta	["alpine fontina", "aosta valley cheese", "dop fontina", "fondue fontina", "italian fontina authentic"]
1035	food coloring	["artificial coloring", "food color", "food dye", "gel food coloring", "liquid food coloring"]
1036	forelle pears	["forelle", "mini pears", "red speckled pears", "small pears", "trout pears"]
1037	fox nuts	["gorgon nuts", "makhana", "phool makhana", "popped water lily", "puffed lotus seeds"]
1038	foxtail millet	["chinese millet", "italian millet", "setaria", "siberian millet", "yellow millet"]
1039	francis mangoes	["caribbean mangoes", "francis", "haitian mangoes", "madame francis", "string free mangoes"]
1040	frank s red hot	["buffalo sauce base", "cayenne pepper sauce", "franks hot sauce", "franks redhot", "wing sauce base"]
1041	freekeh	["farik", "frikeh", "green wheat", "middle eastern grain", "roasted wheat"]
1042	french bread	["artisan french", "baguette", "crusty french bread", "french loaf", "paris bread"]
1043	french dressing	["catalina dressing", "orange french", "red french", "sweet french", "tomato french"]
1044	french feta	["creamier feta", "french sheep feta", "mild feta", "soft feta", "valbreso"]
1045	french lentils	["french green", "lentilles du puy", "peppery lentils", "puy lentils", "slate lentils"]
1046	fresh basil	["basil leaves", "genovese basil", "holy basil alternative", "italian basil", "sweet basil"]
1047	fresh bay leaves	["fresh bay leaf", "fresh laurel", "green bay leaves", "mediterranean bay", "turkish bay fresh"]
1048	fresh chives	["allium", "chive stalks", "fresh chive", "garlic chives alternative", "onion chives"]
1049	fresh cilantro	["chinese parsley fresh", "cilantro leaves", "coriander leaves", "dhania", "fresh coriander"]
1050	fresh dates whole	["fresh date palm", "fresh palm dates", "khalal dates", "rutab dates", "soft fresh dates"]
1051	fresh dill	["anise herb", "dill fronds", "dill leaves", "dill weed", "fresh dill weed"]
1052	fresh durian	["d24 durian", "fresh king fruits", "fresh thorny fruit", "musang king", "ripe durian"]
1053	fresh figs calimyrna	["amber fresh figs", "california fresh figs", "fresh smyrna figs", "fresh yellow figs", "golden figs fresh"]
1054	fresh figs mission	["dark fresh figs", "fresh black mission", "fresh purple figs", "ripe mission", "summer mission figs"]
1055	fresh figs turkey	["everbearing fresh", "fresh brown turkey", "fresh texas figs", "summer brown figs", "sweet fresh figs"]
1056	fresh jackfruit	["fresh artocarpus", "fresh jak", "ripe jackfruit fresh", "whole fresh jackfruit", "young jackfruit"]
1057	fresh lychees	["chinese cherry fresh", "fresh litchi", "fresh tropical lychee", "madagasgar lychee", "mauritius lychee"]
1058	fresh marjoram	["knotted marjoram", "marjoram leaves", "oregano alternative mild", "pot marjoram", "sweet marjoram"]
1059	fresh mint	["garden mint", "mint leaves", "peppermint fresh", "pudina", "spearmint"]
1060	fresh mozzarella	["buffalo mozzarella", "fior di latte", "fresh mozz", "mozzarella ball", "mozzarella di bufala"]
1061	fresh oregano	["greek oregano", "italian oregano", "mediterranean oregano", "oregano leaves", "wild marjoram"]
1062	fresh parsley	["curly parsley", "flat leaf parsley", "fresh garnish", "italian parsley", "parsley sprigs"]
1063	fresh rosemary	["fresh rosemary needles", "garden rosemary", "rosemary branches", "rosemary sprigs", "rosmarinus"]
1064	fresh sage	["broad leaf sage", "common sage", "garden sage", "sage leaves", "salvia"]
1065	fresh sugar apple	["fresh annona squamosa", "fresh atis", "fresh sitaphal", "fresh sweetsop", "ripe sugar apple"]
1066	fresh tamarind	["fresh imli", "fresh tamarindus", "green tamarind", "ripe tamarind", "sweet tamarind pods"]
1067	fresh tarragon	["dragon herb", "estragon", "french tarragon", "little dragon", "tarragon leaves"]
1068	fresh thyme	["english thyme", "french thyme", "garden thyme", "lemon thyme alternative", "thyme sprigs"]
1069	fresh yeast	["block yeast", "brewers yeast fresh", "cake yeast", "compressed yeast", "wet yeast"]
1070	fresno peppers	["california chile", "fresno chiles", "fresno chilies", "hot red peppers", "red jalapenos"]
1288	jabuticaba	["brazilian grape tree", "guapuru", "jaboticaba", "myrciaria", "yvapuru"]
1071	fried rice seasoning	["asian fried rice seasoning", "chinese rice seasoning", "fried rice mix", "instant fried rice mix", "stir fry rice seasoning"]
1072	fried tofu	["aburage", "deep fried tofu", "fried bean curd", "golden tofu", "tofu puffs"]
1073	frisée	["chicorée frisée", "curly chicory", "curly endive", "french frisee", "frisee"]
1074	frog legs	["bullfrog legs", "cuisses de grenouille", "edible frog", "frogs legs", "rana"]
1075	fromage blanc	["cultured fresh cheese", "french fromage blanc", "fresh white cheese", "smooth white cheese", "white cheese"]
1076	frozen yogurt	["fro yo", "probiotic frozen dessert", "soft serve yogurt", "tart frozen yogurt", "yogurt ice cream"]
1077	fuji apples	["fresh fuji", "fuji", "fuji variety", "japanese apples", "sweet apples fuji"]
1078	furikake	["japanese rice seasoning", "japanese topping", "nori seasoning", "rice sprinkle", "seaweed sesame"]
1079	fusilli	["corkscrew long", "long fusilli", "spiral spaghetti", "spring pasta", "twisted pasta long"]
1080	fuyu persimmons	["flat persimmons", "fuyu", "japanese fuyu", "non astringent persimmons", "sweet persimmons"]
1081	fuzzy melon	["fuzzy gourd", "hairy gourd", "hairy melon", "little winter melon", "mo gua"]
1082	gai lan	["chinese broccoli", "chinese kale", "jie lan", "kai lan", "white flowering broccoli"]
1083	gala apples	["gala", "gala variety", "new zealand gala", "royal gala", "sweet gala"]
1084	galangal leaves	["asian ginger leaves", "blue ginger leaves", "galangal tops", "pandan alternative", "thai ginger leaves"]
1085	galangal rhizome	["alpinia", "greater galangal root", "laos root", "lengkuas", "siamese ginger root"]
1086	galangal root	["blue ginger", "galangal", "greater galangal", "siamese ginger", "thai ginger"]
1087	galia melon	["galia", "israeli melon", "ogen melon", "sarda melon", "tropical melon"]
1088	garam masala	["garam masalla", "indian spice blend", "masala powder", "mughlai masala", "warm spice mix"]
1089	garden cress	["curly cress", "lepidium", "pepper cress", "pepperwort", "upland cress"]
1090	garlic bread	["buttered garlic bread", "cheesy garlic bread", "garlic baguette", "italian garlic bread", "toasted garlic bread"]
1091	garlic cloves	["fresh garlic", "garlic", "garlic bulbs", "garlic heads", "whole garlic"]
1092	garlic oil	["garlic cooking oil", "garlic flavored oil", "garlic infused oil", "garlic olive oil", "roasted garlic oil"]
1093	garlic powder	["dehydrated garlic", "dried garlic powder", "garlic dust", "ground garlic", "instant garlic"]
1094	garlic salt	["garlic flavored salt", "garlic seasoned salt", "garlic table salt", "salt garlic blend", "seasoned salt garlic"]
1095	gel food coloring	["concentrated food color", "food coloring gel", "icing color", "paste food coloring", "professional food color"]
1096	gelatin	["animal gelatin", "gelatine", "knox gelatin", "powdered gelatin", "unflavored gelatin"]
1097	gelatin sheets	["gelatin leaves", "gold gelatin", "leaf gelatin", "platinum gelatin", "silver gelatin"]
1098	gemelli	["double twisted", "rope pasta", "twin pasta", "twin spirals", "twisted pasta double"]
1099	geoduck clams	["elephant trunk clam", "geoduck", "giant clam", "gweduc", "king clam"]
1100	ghee	["clarified butter indian", "cooking ghee", "desi ghee", "indian ghee", "pure ghee"]
1101	ghee clarified	["ayurvedic ghee", "cooking ghee", "desi ghee pure", "indian clarified butter", "pure ghee"]
1102	ghost pepper oil	["bhut jolokia oil", "extreme heat oil", "indian ghost oil", "superhot oil", "worlds hottest oil"]
1103	ghost peppers	["bhut jolokia", "ghost chili", "indian ghost pepper", "naga jolokia", "worlds hottest pepper"]
1104	giant prawns	["carabineros", "gambas", "large prawns", "mediterranean prawns", "red prawns"]
1105	gim	["dried laver korean", "kim", "korean nori", "korean seaweed snack", "roasted seaweed korean"]
1106	ginger oil	["asian ginger oil", "fresh ginger oil", "spicy ginger oil", "warming ginger", "zingiber oil"]
1107	ginger powder	["dried ginger", "ginger dust", "ground ginger", "jamaican ginger", "powdered ginger"]
1108	ginger root	["fresh ginger", "ginger", "ginger rhizome", "raw ginger", "young ginger"]
1109	ginkgo nuts	["chinese ginkgo", "ginkgo biloba nuts", "ginkgo seeds", "maidenhair nuts", "white nuts"]
1110	gjetost	["brown cheese", "brunost", "caramelized cheese", "norwegian goat cheese", "ski queen"]
1111	glass noodles	["bean thread noodles", "cellophane noodles", "chinese vermicelli", "fensi", "transparent noodles"]
1112	glucose syrup	["clear glucose", "confectioners glucose", "corn syrup alternative", "dextrose syrup", "liquid glucose"]
1113	gluten free pasta	["allergen free pasta", "alternative grain pasta", "celiac pasta", "gf pasta", "wheat free pasta"]
1114	glutinous rice flour	["mochi flour", "mochiko", "shiratamako", "sticky rice flour", "sweet rice flour"]
1115	gnocchi	["gnocchi pasta", "italian dumplings", "pillowy pasta", "potato dumplings", "soft dumplings"]
1116	goat cheese	["chevre", "french chevre", "fresh goat cheese", "goat cheese log", "soft goat cheese"]
1117	goat cheese crumbles	["chevre crumbles", "crumbled chevre", "goat cheese crumbled", "salad goat cheese", "soft crumbles"]
1118	goat meat	["cabrito", "chevon", "goat curry meat", "mutton goat", "young goat"]
1119	goat milk	["caprine milk", "fresh goat milk", "goats milk", "raw goat milk", "whole goat milk"]
1120	gochugaru	["hot pepper flakes korean", "kimchi pepper", "korean chili flakes", "korean red pepper", "red chili powder korean"]
1121	gochujang	["fermented chili paste", "gochujang paste", "korean chili paste", "korean hot sauce", "red pepper paste"]
1122	goji berries	["chinese wolfberry", "goji", "lycium barbarum", "matrimony vine", "wolfberries"]
1123	gold kiwifruit	["golden kiwi", "smooth kiwi", "sun gold", "yellow kiwi", "zespri gold"]
1124	golden beets	["golden beetroot", "golden yellow beets", "sunshine beets", "yellow beetroot", "yellow beets"]
1125	golden berries	["cape gooseberry golden", "goldenberries", "husk cherry", "inca berry", "peruvian groundcherry"]
1126	golden chard	["blonde silverbeet", "bright yellow chard", "golden stemmed chard", "sunshine chard", "yellow chard"]
1127	golden delicious apples	["golden apples", "golden delicious", "sweet yellow apples", "yellow delicious", "yellow eating apples"]
1128	golden flax seeds	["blonde flax", "golden flaxseed", "light flax", "mild flax", "yellow flax seeds"]
1129	golden pineapples	["extra sweet pineapple", "golden pineapple", "honey pineapple", "premium pineapple", "yellow pineapple"]
1130	golden raisins	["blonde raisins", "dried sultana grapes", "sultanas", "white raisins", "yellow raisins"]
1131	golden syrup	["british syrup", "invert sugar syrup", "light treacle", "lyles golden syrup", "refiner syrup"]
1132	goose	["canada goose", "domestic goose", "grey goose", "snow goose", "wild goose"]
1133	goose breast	["goose breast meat", "goose fillet", "magret goose", "roasted goose breast", "wild goose breast"]
1134	gooseberries	["cape gooseberries fruit", "chinese gooseberry", "european gooseberry", "gooseberry", "ribes"]
1135	gorgonzola	["cremificato", "dolce gorgonzola", "italian blue cheese", "mild blue cheese", "mountain gorgonzola"]
1136	gouda cheese	["aged gouda", "dutch gouda", "gouda", "smoked gouda", "young gouda"]
1137	graddost	["breakfast cheese sweden", "cream cheese swedish", "full cream swedish", "mild graddost", "swedish table cheese"]
1138	graham cracker crumbs	["crushed graham crackers", "graham cracker crust mix", "graham crumbs", "graham powder", "pie crust crumbs"]
1139	graham crackers	["cinnamon graham", "graham cracker sheets", "honey graham crackers", "pie crust crackers", "whole wheat crackers sweet"]
1140	grain sorghum	["durra", "great millet", "guinea corn", "jowar grain", "milo grain"]
1141	grains of paradise	["aframomum", "african pepper grains", "alligator pepper", "guinea pepper", "melegueta pepper"]
1142	granadilla	["grenadia", "mountain sweet cucumber", "passiflora ligularis", "sweet granadilla", "yellow granadilla"]
1143	granny smith apples	["cooking apples green", "granny smith", "green apples", "smith apples", "tart apples"]
1144	granulated sugar	["cane sugar", "refined sugar", "regular sugar", "table sugar", "white sugar"]
46	grape leaves	["dolma leaves", "grape vine leaves", "preserved vine leaves", "stuffing leaves", "vine leaves"]
1146	grape seed extract oil	["antioxidant grape oil", "concentrated grapeseed", "high polyphenol grapeseed", "red grape oil", "vitis oil"]
1147	grapefruit oil	["breakfast citrus oil", "citrus paradisi oil", "florida grapefruit oil", "pink grapefruit oil", "ruby red oil"]
1148	grapefruits	["breakfast fruit", "citrus paradisi", "fresh grapefruit", "grapefruit", "large citrus"]
1149	grapes	["eating grapes", "fresh grapes", "grape", "seedless grapes", "table grapes"]
1150	grapeseed oil	["grape oil", "grape seed oil", "high heat grapeseed", "refined grapeseed", "wine grape oil"]
1151	grated parmesan	["dried parmesan", "green can cheese", "parmesan powder", "powdered parmesan", "shaker parmesan"]
1152	gravy master	["browning and seasoning sauce", "gravy browner", "instant gravy color", "meat color", "roast color"]
1153	gravy mix	["brown gravy mix", "chicken gravy mix", "gravy packet", "instant gravy", "turkey gravy mix"]
1154	great northern beans	["canned white beans", "dried northern", "haricot beans", "large white beans", "white beans"]
1155	greek dressing	["feta dressing", "greek vinaigrette", "lemon herb dressing", "mediterranean dressing", "tzatziki alternative liquid"]
1156	greek seasoning	["greek spice blend", "gyro seasoning", "hellenic spice", "mediterranean greek seasoning", "santorini blend"]
1158	green banana	["cooking banana", "plantain alternative", "savory banana", "starchy banana", "unripe banana"]
1159	green banana flour	["cooking banana flour", "plantain flour green", "raw banana flour", "resistant starch flour", "unripe banana flour"]
2130	sweet potatoes	["sweet potatoes", "sweet potato", "orange sweet potato", "ipomoea batatas", "batata", "camote", "kumara", "not yams"]
1161	green bell peppers	["bell peppers green", "green bell pepper", "green capsicum", "green peppers", "green sweet peppers"]
1162	green cabbage	["cabbage", "dutch cabbage", "fresh cabbage", "round cabbage", "white cabbage"]
1163	green chiles	["diced green chiles", "hatch chiles canned", "mild green chiles", "ortega chiles", "roasted green chiles"]
1165	green enchilada sauce	["enchilada verde", "green chili sauce", "mexican green sauce", "salsa verde enchilada", "tomatillo enchilada"]
1166	green figs	["adriatic green", "fresh green figs", "light green figs", "pale figs", "verdone figs"]
1167	green grapes	["green seedless grapes", "pale grapes", "sultana grapes", "thompson seedless", "white grapes"]
1168	green leaf lettuce	["green leaf", "green lettuce", "leaf lettuce", "loose leaf lettuce", "salad leaf"]
1169	green lentils	["french lentils alternative", "large green lentils", "puy alternative", "spanish lentils", "whole green lentils"]
1170	green lentils french	["aoc lentils", "lentilles vertes", "pdo lentils", "puy lentils authentic", "slate french lentils"]
1171	green lipped mussels	["greenshell mussels", "kiwi mussels", "large green mussels", "new zealand mussels", "perna canaliculus"]
1172	green mango	["cooking mango green", "raw mango", "sour mango", "thai green mango", "unripe mango"]
1173	green olives	["castelvetrano olives", "manzanilla olives", "pimento olives", "spanish olives", "stuffed olives"]
1175	green papaya	["papaya green", "raw papaya", "shredded green papaya", "thai green papaya", "unripe papaya"]
1176	green peppercorns	["brined green pepper", "fresh peppercorns", "mild peppercorns", "soft pepper", "unripe peppercorns"]
1177	green plantains	["cooking plantains green", "hard plantains", "plantain green", "savory plantains", "unripe plantains"]
1178	green split peas	["dried green peas", "green split", "matar dal", "pea soup beans", "split green"]
1346	kiwifruit	["chinese gooseberry", "fuzzy kiwi", "green kiwi", "kiwi", "kiwi fruit"]
1179	green tomato	["end of season tomato", "firm green tomato", "fried green tomato", "tart tomato", "unripe tomato"]
1180	green tomato relish	["chow chow", "end of garden relish", "mustard relish", "piccalilli", "southern relish"]
1181	green zebra tomatoes	["emerald zebra", "green heirloom", "striped tomatoes", "tangy green tomatoes", "yellow striped green"]
1182	grits	["corn grits", "hominy grits", "southern grits", "stone ground grits", "white grits"]
50	ground beef	["beef mince", "burger meat", "ground chuck", "hamburger meat", "minced beef"]
1184	ground cardamom	["cardamom dust", "cardamom powder", "crushed cardamom", "elaichi powder", "powdered cardamom"]
1185	ground cherries	["dwarf cape gooseberry", "husk cherries", "physalis pruinosa", "poha berries", "strawberry tomato"]
1186	ground chicken	["chicken burger meat", "chicken mince", "ground white meat", "lean ground chicken", "minced chicken"]
1187	ground chuck	["80/20 ground beef", "burger chuck", "chuck mince", "fatty ground beef", "ground beef chuck"]
1188	ground cloves	["clove dust", "clove powder", "cloves ground", "dried cloves", "powdered cloves"]
1189	ground duck	["duck burger meat", "duck mince", "duck sausage meat", "ground duck meat", "minced duck"]
1190	ground flax seeds	["flax meal", "flax seed meal", "flaxseed powder", "ground flaxseed", "milled flaxseed"]
1191	ground lamb	["ground mutton", "lamb burger meat", "lamb meatball mix", "lamb mince", "minced lamb"]
51	ground pork	["ground pig", "ground pork meat", "minced pork", "pork burger meat", "pork mince", "pork sausage meat"]
1193	ground round	["85/15 ground beef", "ground beef round", "medium ground beef", "round mince", "semi-lean beef"]
1194	ground sirloin	["90/10 ground beef", "extra lean beef", "ground beef sirloin", "lean ground beef", "sirloin mince"]
1195	ground turkey	["ground turkey meat", "lean ground turkey", "minced turkey", "turkey burger meat", "turkey mince"]
1196	ground veal	["ground calf", "minced veal", "veal burger", "veal meatball mix", "veal mince"]
1197	grouper	["black grouper", "gag grouper", "grouper fillet", "jewfish", "red grouper"]
1198	grouse	["game bird grouse", "prairie chicken", "ruffed grouse", "sage grouse", "spruce grouse"]
4	baking soda	["nahco3", "bicarb", "bicarbonate of soda", "bread soda", "cooking soda", "sodium bicarbonate"]
1200	guacamole	["avocado dip", "avocado spread", "fresh guacamole", "guac", "mexican guacamole"]
1201	guajillo peppers	["chile guajillo", "dried guajillo", "guajillo chiles", "mirasol peppers", "travieso chiles"]
1202	guar gum	["cluster bean gum", "guar flour", "guaran", "stabilizer guar", "thickening agent guar"]
1203	guava	["apple guava", "common guava", "guavas", "psidium", "tropical guava"]
1204	guinea fowl	["african pheasant", "game bird guinea", "guinea hen", "numida", "pintade"]
8	bay leaves	["california bay", "turkish bay leaf", "bay laurel", "bay leaf", "laurel leaves", "sweet bay", "tej patta", "turkish bay leaves"]
521	black beans	["black mexican beans", "black turtle beans", "canned black beans", "dried black beans", "frijoles negros"]
1207	hachiya persimmons	["acorn persimmons", "astringent persimmons", "hachiya", "heart shaped persimmons", "soft persimmons"]
1208	haddock	["atlantic haddock", "finnan haddie", "haddock fillet", "scrod", "smoked haddock"]
1209	halawi dates	["amber dates", "delicate dates", "honey dates halawi", "soft halawi", "sweet dates"]
1211	halibut	["atlantic halibut", "flatfish halibut", "halibut fillet", "pacific halibut", "white halibut"]
1212	halloumi	["brined halloumi", "cypriot cheese", "frying cheese", "grilling cheese", "squeaky cheese"]
1213	ham steak	["bone-in ham steak", "breakfast ham", "center cut ham", "grilling ham", "ham slice"]
1214	hamburger buns	["burger buns", "kaiser buns alternative", "round buns", "sandwich buns", "sesame seed buns"]
1215	harissa	["harissa paste", "maghreb paste", "north african chili paste", "red pepper paste", "tunisian hot sauce"]
1216	harissa paste	["maghreb chili", "north african chili paste", "red pepper paste harissa", "spicy harissa", "tunisian harissa"]
1217	hatch chiles	["hatch peppers green", "hatch valley peppers", "mild hatch chiles", "new mexico chiles", "roasted hatch"]
1218	havarti	["cream havarti", "creamy havarti", "danish havarti", "mild havarti", "semi-soft havarti"]
1219	hawaiian papayas	["rainbow papaya", "small papaya", "solo papaya", "strawberry papaya", "sunrise papaya"]
1220	hawthorn berries	["crataegus", "haw", "mayblossom", "thornapple", "whitethorn berry"]
1221	hazelnut flour	["blanched hazelnut flour", "filbert flour", "ground hazelnuts", "hazelnut meal", "hazelnut powder"]
1222	hazelnut milk	["dairy free hazelnut", "filbert milk", "hazelnut beverage", "nut milk hazelnut", "plant hazelnut milk"]
1223	hazelnut oil	["filbert oil", "nut oil hazelnut", "refined hazelnut", "roasted hazelnut oil", "toasted hazelnut"]
1224	hazelnut paste	["gianduja base", "hazelnut butter", "praline paste hazelnut", "roasted hazelnut paste", "smooth hazelnut paste"]
1225	hazelnut spread	["chocolate hazelnut spread", "cocoa hazelnut", "gianduja spread", "italian hazelnut spread", "nutella style"]
1226	hazelnuts	["filberts", "oregon hazelnuts", "raw hazelnuts", "shelled hazelnuts", "whole hazelnuts"]
1227	hearts of palm	["chonta", "palm cabbage", "palm hearts", "palmito", "swamp cabbage"]
1228	hearts of palm pasta	["keto pasta", "low carb pasta", "palm heart noodles", "palmini", "vegetable noodles"]
1229	hearts of romaine	["baby romaine", "crisp romaine hearts", "little gem lettuce", "romaine centers", "romaine hearts"]
1231	heirloom tomatoes	["artisan tomatoes", "heirloom tomato", "heritage tomatoes", "specialty tomatoes", "vintage tomatoes"]
1232	heirloom tomatoes mixed	["artisan tomato variety", "assorted heirloom tomatoes", "heritage tomato blend", "mixed heirloom tomatoes", "specialty tomato mix"]
1233	heirloom vegetables	["antique vegetables", "heritage vegetable mix", "non-hybrid vegetables", "old variety vegetables", "traditional varieties"]
1230	heavy cream	["36% cream", "double cream", "heavy whipping cream", "thick cream", "whipping cream heavy"]
1210	half and half	["10% cream", "coffee cream", "half and half cream", "half cream", "table cream"]
1234	hemp milk	["dairy free hemp", "hemp beverage", "hemp drink", "hemp seed milk", "plant hemp milk"]
1235	hemp oil	["cannabis seed oil", "cold pressed hemp", "green oil hemp", "hemp seed oil culinary", "omega hemp"]
1236	hemp protein powder	["hemp powder", "hemp protein", "hemp seed protein", "plant protein hemp", "vegan hemp protein"]
1237	hemp seed oil	["cannabis oil culinary", "cold pressed hemp", "green hemp oil", "hemp oil", "refined hemp"]
1238	hemp seeds	["hemp hearts", "hemp kernels", "hulled hemp seeds", "raw hemp seeds", "shelled hemp"]
1239	herb infused oil	["basil oil", "herb olive oil", "mediterranean oil", "rosemary oil", "thyme oil"]
1240	herbs de provence	["french herb blend", "herbes de provence", "lavender herb mix", "provence herbs", "southern french herbs"]
1241	herring	["atlantic herring", "bloater", "kippered herring", "pacific herring", "pickled herring"]
1242	hibiscus flowers	["edible hibiscus", "jamaica flowers", "red hibiscus", "roselle", "sorrel flowers"]
1243	hijiki	["black seaweed", "dried hijiki", "hiziki", "japanese hijiki", "sargassum"]
1244	himalayan pink salt	["himalayan salt", "mineral salt", "pakistani salt", "pink salt", "rock salt pink"]
1245	himalayan red rice	["high altitude red", "himalayan whole grain", "nepalese red rice", "red mountain rice", "tibetan red rice"]
1246	hoisin sauce	["asian plum sauce", "chinese barbecue sauce", "hoisin glaze", "peking sauce", "sweet bean sauce"]
1247	hollandaise sauce mix	["bearnaise alternative mix", "egg sauce mix", "hollandaise packet", "instant hollandaise", "knorr hollandaise"]
52	honey	["clover honey", "liquid honey", "pure honey", "raw honey", "wildflower honey"]
1249	honey mustard	["golden honey mustard", "honey dijon", "honeyed mustard", "sweet and tangy mustard", "sweet mustard"]
1250	honey mustard dressing	["chicken tender sauce", "honey dijon dressing", "honey mustard sauce", "pretzel dipping sauce", "sweet honey mustard"]
1251	honey roasted peanuts	["candied peanuts", "glazed peanuts", "honey coated", "honey peanuts", "sweet peanuts"]
1252	honeycrisp apples	["crispy sweet apples", "honey crisp", "honeycrisp", "minnesota apples", "premium apples"]
1253	honeydew melon	["bailan melon", "green melon", "honeydew", "sweet honeydew", "winter melon honeydew"]
1254	horned melon	["african horned cucumber", "blowfish fruit", "hedgehog gourd", "jelly melon", "kiwano"]
1255	horned melon fresh	["fresh african cucumber", "fresh hedgehog gourd", "fresh jelly melon", "fresh kiwano", "ripe horned melon"]
1256	horseradish	["grated horseradish", "horseradish sauce", "hot horseradish", "prepared horseradish", "white horseradish"]
1257	horseradish oil	["armoracia oil", "hot horseradish", "pungent root oil", "sinus clearing oil", "wasabi oil alternative"]
1258	horseradish root	["fresh horseradish", "mountain radish", "prepared horseradish root", "red cole", "white root horseradish"]
1259	horseshoe crab	["asian horseshoe", "atlantic horseshoe", "king crab alternative", "limulus", "living fossil crab"]
1260	hot dog buns	["frankfurter buns", "hot dog bread", "hot dog rolls", "split top buns", "wiener buns"]
1261	hot italian sausage	["italian hot links", "italian sausage hot", "pizza sausage", "red pepper sausage", "spicy italian sausage"]
1263	hubbard squash	["blue hubbard", "giant hubbard", "green hubbard", "warted hubbard", "winter squash hubbard"]
1264	huckleberries	["huckleberry", "mountain huckleberry", "vaccinium", "western huckleberry", "wild blueberry"]
1265	hulled barley	["brown barley", "dehulled barley", "natural barley", "unpolished barley", "whole grain barley"]
1266	hummus	["chickpea dip", "garbanzo dip", "houmous", "middle eastern dip", "tahini chickpea"]
1267	hushallsost	["everyday swedish", "mild swedish cheese", "swedish household cheese", "swedish semi hard", "vasterbotten alternative"]
1268	hyacinth beans	["dolichos beans", "dried lablab", "egyptian beans", "indian beans", "lablab beans"]
1269	hydroponic lettuce	["butter lettuce hydroponic", "clean lettuce", "greenhouse lettuce", "living lettuce", "soil free lettuce"]
1270	ice cream	["dairy ice cream", "frozen custard alternative", "frozen dessert", "gelato alternative", "sweet cream ice cream"]
1271	iceberg lettuce	["cabbage lettuce", "crisp lettuce", "crisphead lettuce", "head lettuce", "iceberg"]
1272	icelandic yogurt	["cultured skyr", "icelandic skyr", "skyr", "strained skyr", "traditional skyr"]
1273	idli mix	["fermented idli mix", "instant idli", "rice lentil mix", "south indian mix", "steamed cake mix"]
1274	indian green chili	["asian green pepper", "curry pepper", "finger hot pepper", "fresh green chili", "hari mirch"]
1275	instant coffee	["freeze dried coffee", "instant coffee crystals", "instant espresso", "quick coffee", "soluble coffee"]
1276	instant espresso powder	["baking espresso", "concentrated coffee powder", "espresso powder", "instant espresso", "medaglia doro"]
1277	instant rice	["fast rice", "minute rice", "precooked rice", "quick cooking rice", "ready rice"]
1278	instant yeast	["bread machine yeast", "fast acting yeast", "pizza yeast", "quick rise yeast", "rapid rise yeast"]
1279	invert sugar	["conversion sugar", "inverted syrup", "liquid invert sugar", "professional sugar", "trimoline"]
1280	irish moss	["carrageen", "carrageenan source", "chondrus crispus", "red algae", "sea moss"]
1281	israeli couscous	["giant couscous", "lebanese couscous", "maftoul alternative", "pearl couscous", "ptitim"]
1282	italian bread	["ciabatta alternative", "crusty italian bread", "italian loaf", "rustic italian", "white italian bread"]
1283	italian dressing	["herb italian", "italian vinaigrette", "red wine italian", "wishbone italian style", "zesty italian"]
1284	italian sausage	["fennel sausage", "italian links", "mild italian sausage", "pasta sausage", "sweet italian sausage"]
1285	italian seasoning	["italian herb blend", "italian herbs", "mediterranean blend", "pasta herbs", "pizza seasoning"]
1286	italian seasoning blend	["italian herb mix", "mediterranean italian blend", "pasta seasoning", "pizza spice", "tuscan seasoning"]
1287	ivy gourd	["coccinia", "gentleman toes", "kowai fruit", "scarlet gourd", "tindora"]
1289	jabuticaba fresh	["fresh brazilian grape", "fresh guapuru", "fresh myrciaria", "fresh tree grape", "ripe jabuticaba"]
1290	jabuticaba fruit	["brazilian grape", "guapuru fruit", "jaboticaba fresh", "myrciaria cauliflora", "tree grape"]
1291	jackfruit	["artocarpus", "jack fruit", "jak fruit", "tree fruit", "tropical jackfruit"]
1292	jacob cattle beans	["appaloosa beans", "calypso beans similar", "dalmatian beans", "dried jacob", "trout beans"]
1293	jade pearl rice	["bamboo infused", "bamboo rice", "chlorophyll rice", "emerald rice", "green rice"]
1296	jam	["fruit jam", "fruit spread", "grape jam", "preserves", "strawberry jam"]
1297	japanese eggplant	["asian eggplant", "chinese eggplant", "long eggplant", "oriental eggplant", "slender eggplant"]
1298	japanese mayonnaise	["asian mayo", "japanese mayo", "kewpie mayo", "msg mayo", "tokyo mayo"]
1299	japanese sweet potatoes	["asian sweet potato", "japanese yam", "murasaki sweet potato", "oriental sweet potato", "purple sweet potato"]
1300	japanese vegetables	["asian specialty vegetables", "asian vegetable mix", "eastern vegetables", "japanese produce", "oriental vegetables fresh"]
1301	jarlsberg	["mild swiss", "norwegian swiss", "nutty swiss", "scandinavian swiss", "semi-soft swiss"]
1302	jasmine flowers	["arabian jasmine", "edible jasmine", "fragrant jasmine", "jasmine blossoms", "white jasmine"]
1303	jasmine rice	["aromatic jasmine", "asian rice", "fragrant jasmine", "thai rice", "white jasmine rice"]
1304	jazz apples	["designer apples", "jazz", "new zealand jazz", "premium jazz", "scifresh"]
1305	jelly	["clear jam", "fruit gel", "fruit jelly", "grape jelly", "seedless jam"]
1306	jerk seasoning	["caribbean jerk spice", "island spice", "jamaican jerk", "jamaican seasoning", "jerk rub"]
1307	jerusalem artichokes	["earth apple", "jerusalem artichoke tubers", "sunchokes", "sunroot", "topinambur"]
1308	jicama	["jicama root", "mexican potato", "mexican turnip", "mexican yam bean", "yam bean"]
1309	jimmy nardello peppers	["frying peppers jimmy", "heirloom sweet pepper", "italian frying pepper sweet", "long sweet italian", "red frying pepper"]
1310	job tears	["adlay", "chinese pearl barley", "coix seed", "hato mugi", "tear grass"]
1311	jonagold apples	["belgian apples", "hybrid apples", "jonagold", "large apples jonagold", "sweet tart apples"]
1312	jonah crab	["atlantic rock crab", "brown crab", "cancer borealis", "new england crab", "rock crab"]
1313	jujube	["chinese date", "indian jujube", "red date", "tsao", "ziziphus"]
1314	jumbo shells	["baking shells", "conchigioni", "giant pasta shells", "large shells", "stuffing shells"]
1315	jumbo shrimp	["colossal shrimp", "extra large shrimp", "king prawns", "large prawns", "tiger shrimp"]
1316	juustoleipa	["baked cheese", "bread cheese", "finnish squeaky cheese", "grilling cheese finnish", "leipajuusto"]
1317	kabocha squash	["japanese pumpkin", "japanese squash", "kabocha", "kent pumpkin", "winter squash kabocha"]
1318	kadota figs	["dottato", "green figs", "honey figs", "white figs kadota", "yellow figs"]
18	caesar dressing	["caesar salad dressing", "anchovy dressing", "caesar sauce", "creamy caesar", "garlic caesar", "parmesan dressing"]
25	chickpeas	["bengal gram", "bengal gram", "ceci beans", "chana", "dried chickpeas", "garbanzo beans"]
1322	kale leaves	["borecole", "curly kale", "kale", "leaf cabbage", "scots kale"]
1323	kalijira rice	["baby basmati", "bangladeshi basmati", "gobindobhog", "miniature rice", "miniket rice"]
1324	kamut	["ancient kamut", "khorasan wheat", "king tut wheat", "oriental wheat", "pharaoh grain"]
1325	kangaroo meat	["australian kangaroo", "game meat kangaroo", "kangaroo steak", "marsupial meat", "roo meat"]
1326	kaniwa	["andean grain", "baby quinoa", "canihua", "kañiwa", "mini quinoa"]
1327	kashkaval	["balkan cheddar", "bulgarian yellow", "pasta filata balkan", "sheep kashkaval", "yellow cheese balkan"]
1328	kefir	["drinkable yogurt", "fermented milk drink", "kefir milk", "liquid yogurt", "probiotic kefir"]
1329	kefir grains	["fermentation grains", "kefir culture", "living grains", "milk kefir grains", "tibicos dairy"]
1330	keitt mangoes	["fiberless mangoes", "green mangoes ripe", "keitt", "late season mangoes", "sweet keitt"]
1331	kelp	["brown seaweed", "kombu", "laminaria", "pacific kelp", "sea kelp"]
1332	kelp noodles	["low calorie noodles", "raw noodles", "sea kelp noodles", "seaweed noodles", "transparent kelp"]
1333	kencur	["aromatic ginger", "kaempferia", "kencur root", "kentjur", "lesser galangal"]
1334	kent mangoes	["export mangoes", "florida kent", "kent", "large mangoes", "sweet mangoes"]
1335	ketchup	["catsup", "heinz ketchup style", "red sauce", "tomato ketchup", "tomato sauce ketchup"]
1336	key limes	["bartenders lime", "key lime", "mexican limes", "tiny limes", "west indian limes"]
1337	khadrawy dates	["california soft dates", "dark soft dates", "fragile dates", "khadrawi dates", "soft khadrawy"]
1338	kidney beans	["canned kidney", "dark red kidney", "dried kidney beans", "rajma", "red kidney beans"]
1339	kielbasa	["garlic sausage", "kolbasa", "polish sausage", "polska kielbasa", "smoked kielbasa"]
1340	kimchi	["fermented vegetables", "korean fermented cabbage", "korean pickle", "napa kimchi", "spicy kimchi"]
1341	king crab	["alaskan king crab", "giant crab", "kamchatka crab", "king crab legs", "red king crab"]
1342	king oyster mushrooms	["french horn mushroom", "king brown", "king trumpet", "pleurotus eryngii", "trumpet royale"]
1343	king salmon	["blackmouth", "chinook salmon", "king", "spring salmon", "tyee"]
1344	kirby cucumbers	["gherkin cucumbers", "kirby", "pickling cucumbers", "pickling cukes", "small cucumbers"]
1345	kitchen bouquet	["beef color", "browning sauce", "caramel coloring sauce", "gravy browning", "gravy enhancer"]
1295	jalapeño peppers	["green chili peppers", "jalapeno", "jalapenos", "jalapeños", "mexican peppers"]
1294	jalapeño oil	["hot green oil", "jalapeno infused oil", "mexican pepper oil", "spicy jalapeño", "tex mex oil"]
1347	kohlrabi	["cabbage turnip", "german turnip", "knol-khol", "stem turnip", "turnip cabbage"]
1348	kola nut	["bitter cola", "caffeine nut", "cola nut", "guru nut", "west african nut"]
1349	kosher salt	["coarse salt", "diamond crystal", "flaky salt", "kashering salt", "koshering salt"]
1350	koshihikari rice	["niigata rice", "premium japanese rice", "short grain japanese premium", "sushi rice premium", "sweet japanese rice"]
1351	krill	["antarctic krill", "euphausia", "ice krill", "plankton shrimp", "small shrimp"]
1352	krill oil	["antarctic krill oil", "astaxanthin oil", "marine oil", "omega 3 krill", "red oil"]
1353	kumquats	["golden nugget", "kumquat", "little oranges", "nagami kumquat", "oval kumquat"]
1354	labneh	["kefir cheese", "lebanese yogurt", "mediterranean yogurt cheese", "strained yogurt cheese", "yogurt cheese"]
1355	labneh balls	["labneh cheese balls", "marinated labneh", "mediterranean cheese balls", "strained yogurt balls", "yogurt cheese balls"]
1356	lacinato kale	["black kale", "cavolo nero", "dino kale", "dinosaur kale", "tuscan kale"]
1357	lactose free milk	["dairy milk lactose free", "digestive milk", "enzyme treated milk", "lactaid style milk", "lactose reduced"]
1358	ladyfingers	["boudoir biscuits", "italian ladyfingers", "savoiardi", "sponge fingers", "tiramisu cookies"]
1359	lamb chops	["frenched lamb", "lamb cutlets", "lamb loin chops", "lamb rib chops", "single rib chops"]
1360	lamb loin	["boneless loin", "lamb backstrap", "lamb loin roast", "lamb saddle", "lamb tenderloin"]
1361	lamb riblets	["braising ribs lamb", "denver ribs lamb", "lamb breast", "lamb ribs", "spareribs lamb"]
1362	lamb sausage	["greek sausage", "ground lamb sausage", "lamb links", "mediterranean sausage", "rosemary lamb sausage"]
55	lamb shoulder	["bone-in shoulder", "braising lamb", "lamb", "lamb roast", "lamb shoulder chops", "lamb shoulder roast", "shoulder blade", "shoulder of lamb"]
1365	land cress	["american cress", "belle isle cress", "early yellowrocket", "upland garden cress", "winter cress"]
1366	langostino	["chilean langostino", "langostino lobster", "langoustine alternative", "mini lobster tails", "squat lobster"]
1367	langoustine	["dublin bay prawn", "langostino alternative", "nephrops", "norway lobster", "scampi"]
1368	lard	["leaf lard", "manteca", "pork lard", "rendered pork fat", "white lard"]
1369	lasagna noodles	["boil lasagna", "lasagne sheets", "layering pasta", "oven ready lasagna", "wide flat pasta"]
1370	lasagna sheets	["fresh lasagna", "instant lasagna", "lasagne pasta", "no boil lasagna", "pasta sheets"]
1371	lassi	["indian yogurt drink", "mango lassi base", "punjabi lassi", "smoothie yogurt", "sweet lassi"]
1372	lavender buds	["culinary lavender", "dried lavender buds", "english lavender", "lavandula", "purple lavender"]
1373	leaf lard	["baking lard", "kidney lard", "pastry lard", "premium lard", "pure white lard"]
1374	lecithin	["baking lecithin", "emulsifier", "liquid lecithin", "soy lecithin", "sunflower lecithin"]
1375	leeks	["baby leeks", "leek", "pot leeks", "wild leeks", "young leeks"]
1376	leg of lamb	["bone-in lamb leg", "butterflied lamb leg", "lamb gigot", "lamb leg roast", "whole lamb leg"]
1377	lemon curd	["citrus curd", "english lemon curd", "lemon butter", "lemon custard", "tart lemon spread"]
1378	lemon extract	["citrus lemon extract", "concentrated lemon", "lemon essence", "lemon flavoring", "lemon oil extract"]
1379	lemon oil	["citrus oil", "lemon flavored oil", "lemon infused oil", "lemon olive oil", "meyer lemon oil"]
1380	lemon pepper	["citrus pepper", "lemon black pepper", "lemon peel pepper", "lemon pepper seasoning", "zesty pepper"]
1381	lemongrass	["barbed wire grass", "citronella grass", "fever grass", "lemon grass", "sweet rush"]
1382	lemons	["eureka lemons", "fresh lemons", "lemon", "sour lemons", "yellow lemons"]
1383	lentil flour	["dal flour", "ground lentils", "lentil powder", "pulse flour", "red lentil flour"]
1384	lentil pasta	["gluten free lentil", "green lentil pasta", "high protein lentil", "pulse pasta lentil", "red lentil pasta"]
1385	lentil sprouts	["baby lentils", "germinated lentils", "lentil microgreens", "lentil shoots", "sprouted lentils"]
59	lentils	["brown lentils", "common lentils", "dal", "dried lentils", "green lentils", "lens culinaris", "red lentils"]
1387	licorice root	["gan cao", "glycyrrhiza", "licorice stick", "liquorice root", "sweet root"]
1388	light brown sugar	["blonde brown sugar", "golden brown sugar", "mild molasses sugar", "soft light brown", "tan sugar"]
1390	light mayonnaise	["diet mayo", "lean mayo", "lite mayonnaise", "low fat mayo", "reduced fat mayonnaise"]
1391	light olive oil	["cooking olive oil light", "mild olive oil", "neutral olive oil", "pure light olive", "refined light olive oil"]
1392	light sesame oil	["neutral sesame", "pale sesame oil", "refined sesame oil", "untoasted sesame", "white sesame oil"]
1393	light soy sauce	["japanese soy sauce", "pale soy", "regular soy sauce", "thin soy sauce", "usukuchi"]
28	cinnamon	["cassia cinnamon", "ceylon cinnamon", "cassia", "ceylon cinnamon", "cinnamon powder", "dalchini", "ground cinnamon"]
1395	limburger	["belgian cheese", "limburger cheese", "pungent cheese", "stinky cheese", "washed rind limburger"]
1396	lime oil	["citrus aurantifolia", "cold pressed lime", "key lime oil", "mexican lime oil", "persian lime oil"]
1397	limes	["fresh limes", "green limes", "lime", "persian limes", "tahiti limes"]
1398	limpets	["common limpet", "keyhole limpet", "patella", "rock limpets", "slipper limpets"]
1399	lingonberries	["cowberry", "foxberry", "lingonberry", "mountain cranberry", "red whortleberry"]
1400	linguine	["bavette", "flat spaghetti", "linguini", "little tongues", "narrow fettuccine"]
1401	lion mane mushrooms	["bearded hedgehog", "bearded tooth", "hedgehog mushroom", "lions mane", "pom pom"]
1402	lipstick peppers	["bull horn sweet", "lipstick sweet", "pimento type", "stuffing pepper", "sweet red pepper"]
1389	light cream	["18% cream", "cereal cream", "coffee cream light", "single cream", "table cream light"]
1403	liquid aminos	["amino acid sauce", "bragg liquid aminos", "health aminos", "soy protein liquid", "unfermented soy sauce"]
1404	liquid smoke	["bottled smoke", "condensed smoke", "hickory liquid smoke", "mesquite liquid smoke", "smoke flavoring"]
1405	littleneck clams	["little neck clams", "pasta clams", "small clams", "steamer clams little", "tender clams"]
1406	lo mein noodles	["cantonese noodles", "chinese egg noodles", "lo mein wheat", "soft noodles", "stir fry noodles"]
1407	lobster	["american lobster", "homarus", "live lobster", "maine lobster", "whole lobster"]
1408	lobster tails	["cold water tails", "frozen tails", "rock lobster tails", "spiny lobster", "warm water tails"]
1409	loganberries	["american loganberry", "blackberry raspberry hybrid", "logan berries", "pacific berry logan", "rubus hybrid"]
1410	long beans	["asparagus bean", "bodi beans", "chinese long bean", "snake bean", "yard long"]
1411	long pepper	["indian long pepper", "indonesian pepper", "javanese pepper", "piper longum", "pippali"]
1412	longan fresh	["dimocarpus fresh", "dragon eye fresh", "euphoria fruit", "fresh longan fruit", "thai longan"]
1413	longans	["asian longan", "dimocarpus", "dragon eye", "longan", "tropical longan"]
1414	loquat	["chinese plum", "eriobotrya", "japanese plum", "loquats", "nispero"]
1415	lotus root	["lotus rhizome", "lotus stem", "nelumbo root", "renkon", "sacred lotus root"]
1416	lotus seeds	["dried lotus seeds", "fox nuts alternative", "lotus nuts", "makhana alternative", "nelumbo seeds"]
1417	low fat cottage cheese	["1% cottage cheese", "2% cottage cheese", "diet cottage cheese", "light cottage cheese", "reduced fat cottage"]
1418	low fat yogurt	["2% yogurt", "light yogurt", "part skim yogurt", "reduced fat yogurt", "semi-skimmed yogurt"]
1420	lucuma fresh	["fresh canistel", "fresh eggfruit", "fresh peruvian lucuma", "fresh pouteria lucuma", "ripe lucuma"]
1421	lupin beans	["lupine beans", "lupini beans", "mediterranean lupin", "pickled lupins", "termis"]
1422	lychees	["alligator strawberry", "chinese cherry", "litchi", "lychee", "tropical lychee"]
1423	macadamia butter	["australian nut butter", "buttery macadamia", "creamy macadamia", "macadamia paste", "macadamia spread"]
1424	macadamia milk	["dairy free macadamia", "macadamia beverage", "macadamia drink", "nut milk macadamia", "plant macadamia milk"]
1425	macadamia nut oil	["australian nut oil", "macadamia oil", "pressed macadamia", "refined macadamia", "virgin macadamia oil"]
1426	macadamia nuts	["australian nuts", "macadamias", "raw macadamias", "shelled macadamias", "whole macadamias"]
1427	macaroni	["curved tubes", "elbow macaroni", "mac pasta", "macaroni elbows", "short pasta"]
1428	mace	["ground mace", "javitri", "mace blades", "nutmeg covering", "nutmeg mace"]
1429	mackerel	["atlantic mackerel", "blue mackerel", "boston mackerel", "mackerel fillet", "tinker mackerel"]
1430	madagascar pink rice	["african red rice", "pink cargo rice", "pink rice", "red rice madagascar", "rosy madagascar rice"]
1431	maggi seasoning	["maggi sauce", "protein hydrolysate", "swiss seasoning", "umami liquid", "vegetable protein sauce"]
1432	mahi mahi	["common dolphinfish", "dolphinfish", "dorado", "lampuka", "mahi"]
1433	mahlab	["aromatic mahlab", "cherry kernel spice", "mahleb", "middle eastern spice", "st lucie cherry"]
1434	maitake mushrooms	["dancing mushroom", "hen of the woods", "maitake", "rams head", "sheep head"]
1435	makrut fruit	["bumpy lime fruit", "double lime fruit", "kaffir lime fruit", "thai lime fruit", "wild lime fruit"]
1436	malabar spinach	["basella", "ceylon spinach", "indian spinach", "red vine spinach", "vine spinach"]
1437	malagueta pepper	["african bird pepper", "brazilian pepper", "hot brazilian chili", "pimenta malagueta", "piri piri african"]
1438	malt powder	["diastatic malt alternative", "dried malt", "malt extract powder", "malted barley powder", "malted milk base"]
1439	malt vinegar	["ale vinegar", "british vinegar", "brown vinegar", "fish and chips vinegar", "grain malt vinegar"]
1440	malted milk powder	["diastatic malt", "horlicks", "malt powder", "malted milk", "ovaltine base"]
1441	mamey fresh	["fresh mamey sapote", "fresh pouteria", "fresh red mamey", "fresh zapote", "ripe mamey"]
1442	mamey sapote	["mamey", "pouteria", "red mamey", "tropical sapote", "zapote"]
1443	manchego	["aged manchego", "firm spanish cheese", "la mancha cheese", "raw manchego", "spanish sheep cheese"]
1444	mandarin oranges	["clementines", "easy peel oranges", "mandarins", "seedless mandarins", "tangerines"]
1445	mango chutney	["fruit chutney mango", "indian mango chutney", "major grey chutney", "spiced mango", "sweet mango chutney"]
1446	mango ginger	["amada ginger", "ambadi", "curcuma amada", "mango turmeric", "yellow ginger mango"]
1447	mangoes	["fresh mangoes", "mango", "tree mangoes", "tropical mango", "yellow mangoes"]
1448	mangosteen	["garcinia", "purple mangosteen", "queen of fruits", "tropical mangosteen", "xango"]
1449	mangosteens fresh	["fresh purple mangosteen", "fresh queen fruits", "fresh tropical mangosteen", "fresh xango", "garcinia fresh"]
1450	manicotti	["cannelloni tubes", "giant shells alternative", "large tubes", "pasta tubes", "stuffing pasta"]
1451	manila clams	["asian clams", "japanese littleneck", "pacific clams", "steamer clams", "venerupis"]
1452	mantis shrimp	["peacock mantis", "prawn killer", "squilla", "stomatopod", "thumb splitter"]
1453	manuka honey	["active manuka", "medicinal honey", "new zealand honey", "tea tree honey", "umf honey"]
1454	manzano bananas	["apple bananas", "finger bananas manzano", "hawaiian apple banana", "latundan", "sweet short bananas"]
1455	maple sugar	["crystallized maple", "dried maple syrup", "granulated maple", "pure maple sugar", "vermont maple sugar"]
1456	maple syrup	["amber maple", "canadian maple syrup", "grade a maple", "pure maple syrup", "vermont syrup"]
1457	maracuja	["golden passion fruit", "passiflora edulis", "sour passion fruit", "tropical passion", "yellow passion fruit"]
1458	mare milk	["airag milk", "equine milk", "fermented mare milk", "horse milk", "kumis milk"]
1459	margarine	["butter substitute", "margarine spread", "spread margarine", "table margarine", "vegetable margarine"]
1460	marinara sauce	["italian tomato sauce", "pasta sauce marinara", "quick marinara", "red sauce", "tomato basil sauce"]
1461	marionberries	["cabernet of blackberries", "marion berry", "marion blackberry", "oregon blackberry", "willamette valley berry"]
1462	marmalade	["bitter orange jam", "citrus preserve", "english marmalade", "orange marmalade", "seville marmalade"]
1463	marrow beans	["dried marrow", "large white beans", "marrowfat beans", "soup beans large", "white runner beans"]
1464	marshmallow fluff	["fluff spread", "marshmallow cream", "marshmallow creme", "marshmallow paste", "spreadable marshmallow"]
1465	marshmallows	["campfire marshmallows", "large marshmallows", "marshmallow", "mini marshmallows", "regular marshmallows"]
1466	marzipan	["67 percent marzipan", "almond candy paste", "european marzipan", "modeling marzipan", "sweet almond paste"]
1467	masala	["curry spice", "garam masala", "indian seasoning", "mixed masala", "spice blend indian"]
1468	mascarpone	["italian cream cheese", "italian mascarpone", "mascarpone cheese", "tiramisu cheese", "triple cream cheese"]
1469	masoor dal	["egyptian lentil dal", "orange lentils dal", "red lentil dal", "salmon lentils", "split red lentils"]
1470	massaman curry paste	["gaeng massaman", "muslim curry paste", "peanut curry paste", "sweet curry paste", "thai massaman"]
1471	matcha powder	["ceremonial matcha", "culinary matcha", "green tea powder", "japanese matcha", "matcha green tea"]
1472	mayapples	["american mandrake", "hog apple", "podophyllum", "racoonberry", "wild lemon"]
1473	mayocoba beans	["canary beans", "dried mayocoba", "mexican yellow beans", "peruano beans", "peruvian beans"]
1474	mayonnaise	["full fat mayo", "hellmanns style", "mayo", "real mayonnaise", "sandwich spread mayo"]
1475	maypop	["american passion fruit", "apricot vine", "passiflora incarnata", "purple passion flower", "wild passion fruit"]
1476	mcintosh apples	["canadian apples", "eastern apples", "mac apples", "mcintosh", "mcintosh red"]
1477	meat glaze	["concentrated stock", "glace", "glace de viande", "meat extract", "reduced stock"]
1478	meat loaf seasoning	["instant meatloaf mix", "italian meatloaf seasoning", "meat loaf spice blend", "meatloaf mix", "meatloaf seasoning packet"]
1479	medjool dates	["california dates", "caramel dates", "king of dates", "large dates", "medjool"]
1480	medlar	["common medlar", "medlars", "mespilus", "open-arse fruit", "winter fruit"]
1481	medlars fruit	["bletting fruit", "common medlar fruit", "mespilus fruit", "openers fruit", "winter medlar"]
1482	mekabu	["reproductive wakame", "seaweed florets", "thick wakame", "undaria root", "wakame root"]
1483	merguez	["harissa sausage", "lamb sausage", "maghreb sausage", "north african sausage", "spicy merguez"]
1484	meringue powder	["dried egg white powder", "egg white substitute", "meringue mix", "powdered egg whites", "royal icing powder"]
1485	mesquite flour	["desert flour", "legume flour", "mesquite meal", "mesquite pod flour", "sweet flour"]
1486	mexican crema	["central american crema", "crema mexicana", "latin crema", "table cream mexican", "thin sour cream"]
1487	mexican papayas	["caribbean papaya", "large papaya", "maradol papaya", "red papaya", "tropical mexican"]
1488	meyer lemons	["chinese lemons", "hybrid lemons", "improved meyer", "meyer lemon", "sweet lemons"]
1489	microgreens	["baby greens", "micro greens", "microherbs", "sprouted greens", "tender greens"]
1490	mild cheddar	["medium cheddar", "mellow cheddar", "new cheddar", "soft cheddar", "young cheddar"]
1491	milk chocolate	["36% chocolate", "baking milk chocolate", "creamy chocolate", "milk chocolate bar", "sweet chocolate"]
1492	milk chocolate chips	["creamy chocolate chips", "hershey chips", "milk baking chips", "milk chocolate morsels", "sweet chocolate chips"]
1493	milk fat	["anhydrous milk fat", "butter fat", "dairy fat", "milk cream fat", "pure milk fat"]
1494	milk powder	["dry milk powder", "instant milk powder", "nonfat dry milk", "powdered milk", "skim milk powder"]
1495	millet	["ancient grain millet", "birdseed grain", "finger millet alternative", "pearl millet", "proso millet"]
1496	mimolette	["aged mimolette", "ball cheese orange", "boule de lille", "french mimolette", "hard orange cheese"]
1497	miners lettuce	["claytonia", "cuban spinach", "indian lettuce", "spring beauty", "winter purslane"]
1498	mini bell peppers	["baby bell peppers", "cocktail peppers", "lunchbox peppers", "snack peppers", "sweet mini peppers"]
1499	mini chocolate chips	["mini semi-sweet", "miniature chocolate chips", "petite chips", "small morsels", "tiny chocolate chips"]
1500	mini watermelon	["baby watermelon", "icebox watermelon", "personal watermelon", "single serve watermelon", "small watermelon"]
1501	mint chutney	["coriander mint chutney", "fresh mint sauce", "green chutney", "indian mint chutney", "pudina chutney"]
1502	mint oil	["candy mint oil", "cooling mint oil", "mentha oil", "peppermint oil culinary", "spearmint oil"]
1503	miracle fruit	["flavor fruit", "miracle berry", "miraculous berry", "sweet prayer berry", "synsepalum dulcificum"]
1504	mirepoix mix	["aromatic vegetables", "cooking base vegetables", "french mirepoix", "holy trinity vegetables", "soup vegetables"]
1505	miso	["bean paste", "fermented soybean paste", "japanese miso", "miso paste", "soybean miso"]
64	miso paste	["fermented soybean paste", "japanese miso", "miso", "red miso", "white miso", "yellow miso"]
1507	miso soup base	["instant miso soup", "japanese miso soup", "miso broth", "red miso soup", "white miso soup"]
1508	mixed bell peppers	["assorted bell peppers", "fajita peppers", "pepper medley", "rainbow peppers", "tri-color peppers"]
1509	mixed candied fruit	["candied fruit medley", "christmas fruit", "fruitcake mix", "glace fruit mix", "tutti frutti"]
1510	mixed nut butter	["artisan nut butter", "assorted nut butter", "blend nut butter", "gourmet nut butter", "multi nut butter"]
1511	mixed nuts	["assorted nuts", "cocktail nuts", "deluxe mixed nuts", "fancy mixed", "party mix nuts"]
1512	mizuna	["japanese mustard greens", "kyona", "miz greens", "potherb mustard", "spider mustard"]
1513	molasses	["baking molasses", "blackstrap molasses", "dark molasses", "robust molasses", "unsulphured molasses"]
1514	mole sauce	["chocolate chili sauce", "complex mexican sauce", "mexican mole", "mole poblano", "oaxacan mole"]
1515	mongongo nut	["african nut", "dried fruit nut", "manketti nut", "mongongo kernel", "ricinodendron"]
1516	monkfish	["anglerfish", "goosefish", "lotte", "monkfish tail", "poor mans lobster"]
1517	monocalcium phosphate	["acidic calcium", "baking acid", "calcium phosphate", "fast acting leavener", "mcp leavener"]
1518	monterey jack	["california jack", "jack cheese", "monterey", "pepper jack plain", "semi-soft jack"]
1519	monterey jack aged	["aged jack", "dry jack", "grating jack", "hard jack cheese", "parmesan alternative jack"]
1520	montmorency cherries	["cooking cherries", "michigan cherries", "pie cherries", "sour cherries", "tart cherries"]
1521	moon drops grapes	["elongated grapes", "moon drop", "moondrop grapes", "teardrop grapes", "witch finger grapes"]
1522	moong dal	["green gram dal", "mung bean dal", "split green gram", "split mung", "yellow moong dal"]
1523	moose meat	["alces", "canadian moose", "game moose", "moose steak", "wild moose"]
1524	morbier	["ash line cheese", "cow milk morbier", "french morbier", "fruity cheese", "layered cheese"]
1525	morel mushrooms	["honeycomb mushroom", "molly moocher", "morchella", "morels", "sponge mushroom"]
1526	moringa leaves	["ben oil tree leaves", "drumstick leaves", "horseradish tree leaves", "malunggay", "miracle tree leaves"]
1527	moringa oil	["african moringa", "ben oil", "drumstick oil", "horseradish tree oil", "miracle tree oil"]
1528	mortgage lifter	["giant pink tomatoes", "giant sandwich tomato", "large heirloom beefsteak", "radiator charlie", "west virginia heirloom"]
1529	moth beans	["dew bean", "dried moth beans", "mat beans", "matki beans", "turkish gram"]
1530	mozuku	["cladosiphon", "japanese mozuku", "okinawan seaweed", "slippery seaweed", "vinegared seaweed"]
1531	mozzarella cheese	["fresh mozzarella alternative", "italian mozzarella", "mozzarella", "pizza cheese", "shredded mozzarella"]
1532	mozzarella pearls	["bocconcini", "ciliegine", "mini mozzarella", "pearl mozzarella", "small fresh mozzarella"]
1533	msg	["accent seasoning", "flavor enhancer", "monosodium glutamate", "umami powder", "ve tsin"]
1534	muenster cheese	["american muenster", "mild muenster", "monastery cheese", "munster", "soft muenster"]
1535	muffin mix	["bakery muffin mix", "blueberry muffin mix", "bran muffin mix", "corn muffin mix", "instant muffin mix"]
1536	muffins	["bakery muffins", "blueberry muffins", "bran muffins", "breakfast muffins", "jumbo muffins"]
1537	mulberries	["black mulberry", "morus", "mulberry", "red mulberry", "white mulberry"]
1538	multigrain bread	["7 grain bread", "harvest bread", "multi grain bread", "seeded bread", "whole grain mix bread"]
1539	mung beans	["dried mung beans", "golden gram", "green gram", "moong beans", "sprouting beans"]
1540	mung dal	["green gram split", "moong dal split", "petite yellow lentils", "split mung beans", "yellow mung"]
1541	mungo sprouts	["black gram sprouts", "indian black gram sprouts", "matpe sprouts", "urad sprouts", "vigna mungo sprouts"]
1542	muscadine grapes	["bull grapes", "muscadines", "scuppernong", "southern grapes", "vitis rotundifolia"]
1543	muscovado sugar	["barbados sugar", "dark muscovado", "moist brown sugar", "raw brown sugar", "unrefined brown sugar"]
1544	mushroom soy sauce	["chinese mushroom soy", "dark mushroom sauce", "mushroom seasoning", "umami mushroom sauce", "vegetarian stir fry sauce"]
66	mushrooms	["button mushrooms", "champignons", "common mushrooms", "cremini mushrooms", "fresh mushrooms", "fungus", "table mushrooms", "white mushrooms"]
67	mussels	["blue mussels", "debearded mussels", "fresh mussels", "mediterranean mussels", "mytilus", "shellfish"]
1547	mustard	["american mustard", "classic mustard", "hot dog mustard", "prepared mustard", "yellow mustard"]
1548	mustard greens	["brown mustard", "chinese mustard", "gai choy", "leaf mustard", "mustard cabbage"]
1549	mustard oil	["bengali oil", "brassica oil", "indian mustard oil", "pungent oil", "sarson ka tel"]
1550	mustard seeds	["black mustard seeds", "brown mustard seeds", "rai", "sarson", "yellow mustard seeds"]
1551	mustard seeds whole	["black mustard whole", "brown mustard whole", "pickling mustard", "whole rai", "yellow mustard seeds whole"]
1552	mysore bananas	["indian bananas", "kadali", "poovan", "south indian banana", "sweet mysore"]
1553	naan bread	["garlic naan", "indian flatbread", "naan", "punjabi naan", "tandoori bread"]
1554	napa cabbage	["celery cabbage", "chinese cabbage", "pe-tsai", "wombok", "wong bok"]
1555	naranjilla	["ecuador fruit", "little orange", "lulo", "quito orange", "solanum quitoense"]
1556	naranjilla fresh	["fresh little orange", "fresh lulo", "fresh quito orange", "fresh solanum quitoense", "ripe naranjilla"]
1558	natto	["fermented soybeans sticky", "japanese natto", "natto beans", "sticky beans", "stringy soybeans"]
1559	natural food coloring	["fruit based coloring", "natural dyes", "organic food color", "plant based food dye", "vegetable food coloring"]
1560	natural peanut butter	["no sugar peanut butter", "oil separated", "organic peanut butter", "pure peanut butter", "unsweetened peanut butter"]
1561	navel oranges	["california navels", "navel", "seedless oranges navel", "washington navels", "winter oranges"]
1562	navy beans	["boston beans", "dried navy beans", "haricot blanc", "pea beans", "small white beans"]
1563	nectarines	["fuzzless peaches", "nectarine", "smooth peaches", "stone fruit nectarine", "yellow nectarines"]
1564	neem oil	["azadirachta oil", "bitter oil", "indian neem oil", "margosa oil", "nimba oil"]
1565	neufchatel	["french cream cheese", "light cream cheese", "lower fat spreadable", "neufchatel cheese", "reduced fat cream cheese"]
1566	new potatoes	["baby potatoes", "creamers", "early potatoes", "marble potatoes", "petite potatoes"]
1567	new york strip steak	["kansas city strip", "ny strip", "shell steak", "strip steak", "top loin"]
1568	new zealand spinach	["botany bay spinach", "kokihi", "sea spinach", "tetragonia", "warrigal greens"]
1569	nicoise olives	["cailletier olives", "french olives", "provence olives", "small black olives", "tiny black olives"]
1570	nigella seeds	["black cumin", "black onion seeds", "charnushka", "kalonji", "nigella sativa"]
1571	nokkelost	["clove cheese", "key cheese", "norwegian cumin cheese", "nøkkelost", "spiced norwegian"]
1572	nonfat yogurt	["0% yogurt", "diet yogurt", "fat free yogurt", "no fat yogurt", "skim yogurt"]
1573	nonpareils	["disco dust alternative", "micro sprinkles", "round sprinkles", "sugar balls", "tiny ball sprinkles"]
1574	nopales	["cactus pads", "mexican cactus", "nopalitos", "paddle cactus", "prickly pear pads"]
1575	nori sheets	["dried nori", "laver sheets", "roasted nori", "seaweed paper", "sushi nori"]
1576	nut and seed clusters	["crunchy clusters", "granola clusters", "honey nut clusters", "nut clusters", "seed clusters"]
68	nutmeg	["ground nutmeg", "jaiphal", "mace alternative", "mystica", "nutmeg powder", "whole nutmeg"]
1579	nutmeg oil	["baking spice oil", "christmas oil", "jaiphal oil", "myristica oil", "warm nutmeg oil"]
1580	oat bran	["oat cereal bran", "oat fiber", "oat hull", "oat mill", "soluble fiber oats"]
1581	oat flour	["ground oats", "milled oats", "oat powder", "oatmeal flour", "whole oat flour"]
1582	oat milk	["dairy free oat", "oat beverage", "oat drink", "oat mylk", "plant oat milk"]
1583	oat yogurt	["dairy free oat yogurt", "grain yogurt", "oat milk yogurt", "plant oat yogurt", "vegan oat yogurt"]
1584	oats	["hulled oats", "oat grain", "oat groats", "oat kernels", "whole oats"]
1585	oaxaca cheese	["asadero", "melting cheese mexican", "mexican string cheese", "oaxacan string", "quesadilla cheese"]
1586	oca	["ibia", "new zealand yam", "uqa", "wood sorrel tuber", "yam oca"]
1587	octopus	["baby octopus", "fresh octopus", "octopus tentacles", "tako", "whole octopus"]
1588	octopus tentacles	["boiled tentacles", "octopus arms", "octopus legs", "tako tentacles", "tentacle meat"]
1589	ogonori	["gracilaria", "hawaiian seaweed", "limu", "ogo", "red seaweed edible"]
1590	ogosuri	["fine ogo", "gracilaria thin", "hawaiian ogosuri", "limu manauea", "red seaweed thin"]
1591	okara	["soy fiber", "soy pulp", "soybean dregs", "tofu lees", "unohana"]
1592	okonomiyaki sauce	["japanese pancake sauce", "okonomi sauce", "osaka sauce", "savory japanese sauce", "thick brown sauce"]
1593	okra	["bamia", "bhindi", "gumbo", "ladies fingers", "lady fingers"]
1594	old bay seasoning	["chesapeake bay seasoning", "crab boil spice", "maryland seasoning", "old bay style", "seafood seasoning blend"]
1596	olive oil spray	["evoo spray", "extra virgin spray", "mediterranean spray", "olive cooking spray", "olive pam"]
1597	olive tapenade	["black olive tapenade", "mediterranean tapenade", "olive paste", "olive spread", "provencal tapenade"]
73	olives	["black olives", "green olives", "mediterranean olives", "mixed olives", "pitted olives", "table olives"]
1599	onion powder	["dehydrated onion", "dried onion powder", "ground onion", "instant onion", "onion dust"]
1600	onion salt	["onion flavored salt", "onion seasoned salt", "onion table salt", "salt onion blend", "seasoned salt onion"]
1601	onion soup mix	["dry onion soup", "french onion soup mix", "lipton onion soup mix", "onion dip mix", "onion recipe mix"]
1602	orach	["atriplex", "french spinach", "mountain spinach", "red orach", "saltbush"]
1603	orange bell peppers	["bell peppers orange", "orange bell pepper", "orange capsicum", "orange peppers", "orange sweet peppers"]
1604	orange blossom honey	["citrus honey", "floral honey orange", "florida honey", "light citrus honey", "sweet orange honey"]
1605	orange blossom water	["floral water orange", "mazahar", "neroli water", "orange blossom essence", "orange flower water"]
1606	orange cauliflower	["cheddar cauliflower", "colored cauliflower orange", "flame star", "orange bouquet", "orange cauli"]
1607	orange extract	["citrus extract", "concentrated orange", "orange essence", "orange flavoring", "orange oil extract"]
1608	orange oil	["citrus sinensis oil", "cold pressed orange", "orange peel oil", "sweet orange oil", "valencia oil"]
1609	orange oxheart	["flame oxheart", "heart shaped orange", "large orange tomato", "meaty orange heirloom", "orange heirloom"]
1610	oranges	["eating oranges", "fresh oranges", "orange", "sweet oranges", "table oranges"]
1611	orecchiette	["concave pasta", "ear shaped pasta", "italian orecchiette", "little ears pasta", "pugliese pasta"]
1612	oregano oil	["greek oregano oil", "medicinal oregano", "origanum oil", "pizza herb oil", "wild oregano oil"]
1613	oreo cookies	["chocolate cookies", "chocolate sandwich cookies", "cream filled cookies", "oreos", "sandwich creme cookies"]
1614	oro blanco grapefruit	["israeli grapefruit", "oro blanco", "pomelit", "sweetie fruit", "white gold grapefruit"]
1615	orzo	["barley shaped pasta", "grain pasta", "italian rice", "rice shaped pasta", "risoni"]
1616	ossau iraty	["basque sheep cheese", "firm sheep cheese", "french sheep milk", "mountain sheep cheese", "pyrenees cheese"]
1617	ostrich meat	["ostrich fan", "ostrich fillet", "ostrich steak", "ratite meat", "red ostrich meat"]
1618	oxtail	["beef tail", "braising oxtail", "ox tail", "soup oxtail", "tail meat"]
1619	oyster mushrooms	["hiratake", "oyster", "pearl oyster mushroom", "pleurotus", "tree oyster"]
1620	oyster sauce	["chinese oyster sauce", "lee kum kee style", "oyster flavored sauce", "stir fry sauce oyster", "umami sauce"]
1621	oysters	["fresh oysters", "half shell oysters", "live oysters", "raw oysters", "shucked oysters"]
1622	oysters canned	["canned oysters in oil", "canned oysters in water", "pacific oysters canned", "smoked oysters", "whole oysters canned"]
1623	pad thai noodles	["flat rice noodles", "pho noodles flat", "sen lek", "stir fry rice noodles", "thai rice sticks"]
1624	pad thai sauce	["pad thai tamarind", "peanut noodle sauce", "sweet sour thai", "tamarind sauce", "thai noodle sauce"]
1625	padron peppers	["galician peppers", "padron chilies", "pimientos de padron", "spanish peppers", "tapas peppers"]
1626	palm kernel oil	["coconut alternative oil", "hydrogenated palm kernel", "pko", "refined palm kernel", "tropical kernel oil"]
1627	palm oil	["african palm oil", "dendê oil", "red palm oil", "refined palm oil", "sustainable palm oil"]
1628	panang curry paste	["gaeng phanang", "red panang paste", "rich curry paste", "thai panang", "thick curry paste"]
1629	pancake mix	["buttermilk pancake mix", "complete pancake mix", "flapjack mix", "instant pancake mix", "pancake flour"]
1630	pancetta	["guanciale alternative", "italian bacon", "pork belly cured", "rolled pancetta", "unsmoked bacon"]
1631	pandan leaves	["asian vanilla leaves", "fragrant pandanus", "pandanus leaves", "rampe", "screwpine leaves"]
1632	paneer	["cottage cheese pressed indian", "curry cheese", "fresh paneer", "indian cheese", "vegetarian paneer"]
1633	panko	["coarse bread crumbs", "crispy panko", "flaky bread crumbs", "japanese bread crumbs", "panko breadcrumbs"]
1634	pansy flowers	["edible pansies", "heartsease", "johnny jump ups", "viola tricolor", "wild pansy flowers"]
1635	papad	["crispy papad", "indian cracker", "lentil wafer", "papadum", "poppadom"]
1636	papayas	["papaw", "papaya", "pawpaw", "tree melon", "tropical papaya"]
1637	pappardelle	["broad noodles", "egg pappardelle", "large fettuccine", "tuscan pasta", "wide ribbon pasta"]
1638	paprika	["ground paprika", "hungarian paprika", "red pepper paprika", "spanish paprika", "sweet paprika"]
1639	paradise nut	["brazilian paradise", "cream nut", "lecythis", "monkey pot nut", "sapucaia nut"]
1640	parboiled rice	["converted rice", "easy cook rice", "pre-steamed rice", "quick rice", "uncle bens style"]
1642	parmigiano reggiano	["aged parmigiano", "authentic parmesan", "italian parmesan", "parmesan reggiano", "pdo parmesan"]
1643	parsnips	["cultivated parsnip", "garden parsnip", "parsnip", "white carrot", "wild parsnip"]
1644	part skim ricotta	["diet ricotta", "lean ricotta", "light ricotta", "low fat ricotta", "reduced fat ricotta"]
1645	partridge	["chukar partridge", "game bird partridge", "gray partridge", "hungarian partridge", "red legged partridge"]
1646	pasilla peppers	["black chile", "chile negro", "dried chilaca", "mexican negro", "pasilla chiles"]
1647	passion fruit	["lilikoi", "maracuja", "parcha", "passionfruit", "purple granadilla"]
1648	pasta sauce	["italian pasta sauce", "ragu style", "red pasta sauce", "spaghetti sauce", "tomato pasta sauce"]
1649	pastry flour	["biscuit flour", "cookie flour", "light pastry flour", "medium flour", "pie flour"]
1650	pawpaws	["asimina", "custard apple pawpaw", "hoosier banana", "michigan banana", "pawpaw fruit"]
1651	pea milk	["pea beverage", "pea protein milk", "plant pea milk", "ripple milk style", "yellow pea milk"]
1652	pea protein powder	["pea powder", "pea protein isolate", "plant protein pea", "vegan protein pea", "yellow pea protein"]
1653	pea shoots	["pea greens", "pea sprouts", "pea tendrils", "pea vine tips", "snow pea shoots"]
1654	peaches	["fresh peaches", "peach", "stone fruit peach", "tree peaches", "yellow peaches"]
1655	peanut butter	["creamy peanut butter", "natural peanut butter", "regular peanut butter", "smooth peanut butter", "spreadable peanut butter"]
1656	peanut butter chips	["pb chips", "pb morsels", "peanut butter baking pieces", "peanut butter morsels", "reeses baking chips"]
1657	peanut butter smooth	["creamy peanut butter jar", "jar peanut butter", "jif style", "smooth pb", "spreadable peanut butter"]
1658	peanut oil	["arachis oil", "cooking peanut oil", "groundnut oil", "refined peanut oil", "roasted peanut oil"]
1659	peanut sauce	["asian peanut", "dipping sauce peanut", "peanut butter sauce", "satay sauce", "thai peanut sauce"]
1660	peanuts	["raw peanuts", "roasted peanuts", "shelled peanuts", "spanish peanuts", "virginia peanuts"]
1661	pearl barley	["polished barley", "processed barley", "quick barley", "refined barley", "white barley"]
1662	pearl sugar	["decorating sugar coarse", "hail sugar", "nib sugar", "pretzel sugar", "swedish pearl sugar"]
1663	pears	["eating pears", "fresh pears", "pear", "table pears", "tree pears"]
1664	peas and carrots	["classic vegetable mix", "garden medley", "mixed vegetables peas carrots", "pea carrot mix", "peas carrot blend"]
1665	pecan butter	["creamy pecan butter", "natural pecan butter", "pecan paste", "pecan spread", "southern nut butter"]
1666	pecan oil	["nut oil pecan", "pressed pecan oil", "refined pecan", "roasted pecan oil", "southern nut oil"]
1667	pecan pieces	["baking pecans", "broken pecans", "chopped pecans", "pecan bits", "pecan chips"]
1668	pecans	["paper shell pecans", "pecan halves", "raw pecans", "shelled pecans", "texas pecans"]
1669	pecorino romano	["grating romano", "hard pecorino", "pecorino", "roman cheese", "sheep romano"]
1670	pectin	["apple pectin", "fruit pectin", "jam pectin", "preserving pectin", "sure jell"]
1671	peekytoe crab	["atlantic rock crab maine", "bay crab", "maine rock crab", "picked toe crab", "rock crab maine"]
1672	pen shell	["fan mussel", "mediterranean mussel", "nacre shell", "noble pen shell", "pinna nobilis"]
1673	penne	["pen pasta", "penne lisce", "penne rigate", "quill pasta", "tube pasta"]
1674	pepino fresh	["fresh pepino melon", "fresh solanum muricatum", "fresh sweet cucumber", "fresh tree melon", "ripe pepino"]
1675	pepino melon	["melon pear", "pepino dulce", "solanum muricatum", "sweet cucumber", "tree melon"]
1676	peppadew peppers	["jarred peppadew", "mild sweet pepper", "pickled sweet pepper", "south african pepper", "sweet piquante"]
1677	pepper jack	["chile jack", "hot pepper jack", "jalapeno jack", "mexican jack", "spicy jack cheese"]
1678	peppermint chips	["andes chips", "candy cane chips", "chocolate mint chips", "mint baking chips", "mint chips"]
1679	peppermint extract	["concentrated mint", "mint essence", "mint extract", "peppermint flavoring", "spearmint extract alternative"]
1680	pepperoncini	["golden greek peppers", "greek peppers", "italian pepperoncini", "mild peppers jarred", "tuscan peppers"]
1681	pequin pepper	["bird pepper", "chile pequin", "chiltepin", "tepin pepper", "tiny hot pepper"]
1682	perch	["freshwater perch", "lake perch", "perch fillet", "striped perch", "yellow perch"]
1683	perilla oil	["asian perilla", "deulgireum", "korean sesame oil", "wild sesame oil", "들기름"]
1684	periwinkles	["common periwinkle", "edible winkle", "littorina", "sea snails", "winkles"]
1685	perpetual spinach	["chard perpetual", "english spinach beet", "leaf beet", "spinach beet", "wild spinach"]
1686	persian cucumbers	["baby cucumbers", "cocktail cucumbers", "lebanese cucumbers", "mini cucumbers", "snacking cucumbers"]
1687	persimmons	["diospyros", "kaki", "oriental persimmons", "persimmon", "sharon fruit"]
1688	pesto	["basil pesto", "genovese pesto", "green pesto", "italian pesto", "pine nut pesto"]
1689	pesto sauce mix	["basil pesto mix", "dry pesto mix", "instant pesto", "italian pesto packet", "pesto seasoning mix"]
1690	pheasant	["game bird pheasant", "pheasant breast", "ring-necked pheasant", "whole pheasant", "wild pheasant"]
1691	pho noodles	["banh pho", "flat pho noodles", "rice sticks wide", "soup noodles vietnamese", "vietnamese rice noodles"]
84	phyllo dough	["fillo dough", "fillo pastry", "filo dough", "filo pastry", "greek phyllo", "paper thin dough", "phyllo pastry", "phyllo sheets"]
1693	phyllo pastry	["fillo dough", "filo pastry", "greek pastry", "paper thin pastry", "phyllo sheets"]
1694	pickle relish	["chopped pickles", "cucumber relish", "hot dog relish", "india relish", "sweet relish"]
1695	pickled ginger	["beni shoga", "gari", "japanese pickled ginger", "pink pickled ginger", "sushi ginger"]
1696	pickled jalapeños	["en escabeche jalapeños", "mexican pickled peppers", "nacho jalapeños", "pickled jalapenos sliced", "sliced jalapeños jarred"]
1697	pickled vegetables	["giardiniera", "italian pickled vegetables", "jardiniere", "mixed pickles", "pickled mix"]
1698	pickled vegetables asian	["asian preserved vegetables", "fermented asian vegetables", "japanese pickles", "korean pickles", "tsukemono"]
1699	pickles	["cucumber pickles", "dill pickles", "kosher dill pickles", "pickle spears", "whole pickles"]
1700	pico de gallo	["chopped tomato salsa", "fresh salsa", "mexican pico", "salsa fresca", "uncooked salsa"]
85	pie crust	["frozen pie crust", "pastry crust", "pastry shell", "pie shell", "ready made pie crust", "refrigerated pie crust", "unbaked pie crust"]
1702	pie dough	["frozen pie dough", "pastry dough", "pie crust dough", "pie shell dough", "refrigerated pie crust"]
1703	pig feet	["front feet", "pigs feet", "pork hocks front", "pork trotters", "trotters pork"]
1704	pigeon peas	["arhar dal", "dried pigeon peas", "red gram", "toor dal", "tur dal"]
1705	pike	["freshwater pike", "jackfish", "northern pike", "pike fillet", "water wolf"]
1706	pili nut	["canarium nut", "java almond", "pacific almond", "philippine nut", "tropical almond"]
1707	pimientos	["cherry peppers sweet", "jarred pimientos", "pimento peppers", "spanish pimientos", "sweet red peppers jarred"]
86	pine nuts	["italian pine nuts", "pignoli", "pignolia nuts", "pine kernels", "pinon nuts"]
1709	pineapples	["ananas", "fresh pineapple", "pineapple", "queen pineapple", "tropical pineapple"]
1710	pink guava	["pink flesh guava", "red guava", "ruby guava", "strawberry guava", "tropical pink guava"]
31	cocoa powder	["dutch-process cocoa", "baking cocoa", "cacao powder", "cocoa", "dutch process alternative", "natural cocoa powder", "pure cocoa", "unsweetened cocoa"]
1712	pink peppercorns	["brazilian pepper", "false pepper", "red peppercorns", "rose peppercorns", "schinus pepper"]
1713	pink peppercorns dried	["baies roses", "dried brazilian pepper", "dried pink berries", "dried rose pepper", "peruvian pepper"]
1714	pink salmon	["canned salmon", "humpback salmon", "humpies", "humpy", "pink"]
1715	pinto beans	["dried pinto beans", "frijoles pintos", "mexican pinto", "painted beans", "speckled beans"]
1716	piquillo peppers	["jarred piquillos", "pimiento piquillo", "roasted red peppers spanish", "spanish piquillo", "sweet spanish peppers"]
1717	piri piri	["african bird pepper", "african devils", "pequin pepper", "peri peri", "small hot pepper"]
1718	pistachio butter	["creamy pistachio", "green nut butter", "pistachio paste", "pistachio spread", "sicilian pistachio butter"]
1719	pistachio kernels	["green pistachio kernels", "pistachio meats", "pistachio pieces", "shelled pistachio nuts", "sicilian pistachios"]
1720	pistachio milk	["dairy free pistachio", "green nut milk", "pistachio beverage", "plant pistachio milk", "sicilian milk"]
1721	pistachio oil	["green nut oil", "nut oil pistachio", "pressed pistachio oil", "refined pistachio", "sicilian pistachio oil"]
1722	pistachios	["california pistachios", "green nuts", "iranian pistachios", "raw pistachios", "shelled pistachios"]
1724	pita chips	["baked pita chips", "mediterranean chips", "pita bread chips", "pita crisps", "toasted pita"]
1725	pizza dough	["dough ball", "fresh pizza dough", "pizza base", "pizza crust dough", "refrigerated pizza dough"]
1726	pizza sauce	["italian pizza sauce", "pizza marinara", "pizza topping sauce", "red pizza sauce", "uncooked pizza sauce"]
1727	plain yogurt	["fresh yogurt", "natural yogurt", "regular yogurt", "unflavored yogurt", "whole milk yogurt"]
1728	plantain bananas	["baking plantains", "banana plantain", "cooking plantains", "plantain fruit", "platanos maduros"]
1729	plantains	["baking bananas", "cooking bananas", "green plantains", "plantain", "platanos"]
1730	plum sauce	["asian plum", "chinese plum sauce", "duck sauce", "restaurant plum sauce", "sweet plum sauce"]
1731	plums	["fresh plums", "plum", "purple plums", "stone fruit plum", "tree plums"]
1732	pluots	["dapple dandy", "dinosaur egg", "flavor king", "plum apricot hybrid", "plumcots"]
1733	poblano peppers	["fresh poblanos", "mexican poblanos", "poblano chile peppers", "poblano chiles", "poblanos"]
1734	pointed gourd	["green potato", "parval", "parwal", "patola", "potol"]
1735	polenta	["coarse polenta", "instant polenta", "italian cornmeal", "white polenta", "yellow polenta"]
1736	pomegranate molasses	["concentrated pomegranate", "middle eastern molasses", "pomegranate reduction", "pomegranate syrup", "tangy pomegranate"]
1737	pomegranate seed oil	["granada oil", "omega 5 oil", "pomegranate kernel oil", "punica oil", "punicic acid oil"]
1738	pomegranates	["fresh pomegranate", "granada", "pomegranate", "punica granatum", "red fruit pomegranate"]
1739	pomelo	["chinese grapefruit", "giant citrus", "jabong", "pummelo", "shaddock"]
1741	ponzu sauce	["citrus soy sauce", "dipping sauce ponzu", "japanese ponzu", "tangy ponzu", "yuzu ponzu"]
1742	popcorn	["air popped corn", "microwave popcorn", "movie popcorn", "plain popcorn", "popped corn"]
1743	poppy seeds	["baking poppy seeds", "blue poppy seeds", "european poppy", "maw seed", "papaver seeds"]
1744	porcini mushrooms	["cep", "king bolete", "penny bun", "porcini", "steinpilz"]
1745	pork belly	["bacon slab", "fresh pork belly", "side pork", "streaky pork", "uncured bacon"]
1746	pork blood	["black pudding blood", "blood cake", "blood sausage ingredient", "pig blood", "pork plasma"]
1747	pork chops	["bone-in pork chops", "center cut chops", "pork cutlets", "pork loin chops", "rib chops"]
1748	pork ears	["braised pork ears", "crispy pork ears", "fried pig ears", "pig ears", "pork ear cartilage"]
1749	pork fatback	["back fat", "fatback slab", "lardo", "rendering fat", "solid fat"]
1750	pork jowl	["cheek bacon", "guanciale", "hog jowl", "jowl bacon", "pork cheeks"]
1751	pork loin	["boneless pork loin", "center loin roast", "pork backstrap", "pork loin roast", "whole loin"]
1752	pork ribs	["baby back ribs", "bbq ribs", "pork rib rack", "spare ribs", "st louis ribs"]
1753	pork shank	["ham hock", "osso buco pork", "pork knuckle", "pork shin", "pork trotter"]
1755	pork sirloin	["pork hip", "pork loin end", "pork sirloin roast", "sirloin end", "sirloin tip pork"]
1756	pork skin	["chicharron fresh", "crackling skin", "pig skin", "pork rind", "pork rind uncooked"]
1757	pork steak	["blade steak pork", "boston steak", "pork cutlet steak", "pork shoulder blade", "shoulder steak"]
1758	pork tenderloin	["lean pork", "pork fillet", "pork tender", "tenderloin roast pork", "whole tenderloin pork"]
1759	portobello mushrooms	["bella mushrooms", "field mushrooms large", "large cremini", "portabella", "portobello caps"]
1760	pot roast seasoning	["beef roast seasoning", "pot roast packet", "roast seasoning mix", "slow cooker roast mix", "sunday dinner seasoning"]
1761	potash	["baking alkali", "lye alternative", "pearl ash", "potassium carbonate", "traditional leavening"]
1762	potato starch	["fecula", "kartoffelmehl", "potato flour starch", "potato starch flour", "pure potato starch"]
1763	poultry fat	["bird fat", "mixed poultry fat", "poultry drippings", "rendered poultry fat", "turkey chicken fat"]
1764	poultry seasoning	["chicken seasoning", "poultry herbs", "sage blend", "stuffing spice", "turkey seasoning"]
1765	powdered milk	["dehydrated milk", "dry milk powder", "instant dry milk", "milk powder", "nonfat dry milk"]
1766	powdered peanut butter	["defatted peanut butter", "pb2", "peanut butter powder", "peanut flour", "reconstituted pb"]
1767	powdered sugar	["10x sugar", "confectionary sugar", "confectioners sugar", "icing sugar", "powdered icing"]
1768	preserves	["chunky jam", "fruit preserves", "homemade style jam", "thick jam", "whole fruit jam"]
1769	pretzels	["baked pretzels", "hard pretzels", "pretzel sticks", "pretzel twists", "salted pretzels"]
1770	prickly pear fruit	["cactus fruit fresh", "nopal fruit", "opuntia fruit", "sabra fruit", "tuna fruit fresh"]
1771	probiotic yogurt	["acidophilus yogurt", "active yogurt", "beneficial bacteria yogurt", "gut health yogurt", "live culture yogurt"]
1772	processed cheese	["american cheese", "cheese singles", "cheese slices", "melting cheese processed", "sandwich cheese"]
1773	prosciutto	["aged ham", "dry cured ham", "italian ham", "parma ham", "prosciutto crudo"]
1774	proso millet	["broomcorn millet", "common millet", "hog millet", "panicum", "white millet"]
1775	protein crumbles	["meatless crumbles", "soy crumbles", "textured soy crumbles", "tvp crumbles", "vegetarian ground"]
1776	provola	["buffalo provola", "fresh provola", "neapolitan cheese", "provola cheese", "smoked provola"]
1777	provolone cheese	["aged provolone", "italian provolone", "mild provolone", "provolone", "sharp provolone"]
1778	provolone del monaco	["campania provolone", "monk provolone", "sorrentino provolone", "sweet provolone", "young provolone"]
1779	prunes	["california prunes", "dried italian plums", "dried plums", "pitted prunes", "prune fruit"]
1780	puff pastry	["flaky pastry", "frozen puff pastry", "puff pastry sheets", "rough puff", "store bought puff pastry"]
1781	pule cheese	["balkan donkey cheese", "donkey cheese", "magarcevski sir", "serbian pule", "worlds expensive cheese"]
1782	pumpernickel bread	["black bread", "dark pumpernickel", "dense dark bread", "german pumpernickel", "whole rye bread"]
1783	pumpkin	["cooking pumpkin", "fresh pumpkin", "pie pumpkin", "sugar pumpkin", "winter pumpkin"]
1784	pumpkin butter	["autumn pumpkin butter", "pumpkin pie spread", "pumpkin spread", "smooth pumpkin butter", "spiced pumpkin butter"]
1785	pumpkin leaves	["cucurbit leaves", "fluted pumpkin leaves", "pumpkin greens", "squash leaves", "ugu"]
1786	pumpkin pie spice	["autumn spice", "fall spice blend", "pie spice blend", "pumpkin spice", "warm baking spice"]
1787	pumpkin seed oil	["dark green oil", "pepita oil", "pressed pumpkin seed", "squash seed oil", "styrian pumpkin oil"]
1788	pumpkin seeds	["green pumpkin seeds", "hulled pumpkin seeds", "pepitas", "raw pumpkin seeds", "roasted pepitas"]
1789	pumpkin spice oil	["autumn oil", "chai spice oil", "fall flavored oil", "seasonal cooking oil", "spiced oil"]
1790	purple beans	["burgundy beans", "purple green beans", "purple string beans", "purple wax beans", "violet beans"]
1791	purple carrots	["black carrots", "colored carrots", "heritage carrots", "purple carrot", "violet carrots"]
1792	purple cauliflower	["colored cauliflower purple", "graffiti cauliflower", "purple cauli", "sicilian violet", "violet cauliflower"]
1793	purple potatoes	["blue potatoes", "purple majesty", "purple peruvian", "purple potato", "violet potatoes"]
1794	purslane	["little hogweed", "pigweed", "portulaca", "pusley", "verdolaga"]
1795	quail	["coturnix", "european quail", "game bird quail", "japanese quail", "whole quail"]
1796	quark	["curd cheese smooth", "fresh cheese", "fromage blanc", "german quark", "topfen"]
1797	queen anne cherries	["light cherries", "napoleon cherries", "royal ann", "white heart cherries", "yellow sweet cherries"]
1798	queso blanco	["fresh white cheese mexican", "mild white cheese", "panela cheese", "queso blanco fresco", "white cheese latin"]
1799	queso fresco	["farmers cheese mexican", "fresh mexican cheese", "mexican crumbling cheese", "mild queso", "white cheese mexican"]
1800	quick oats	["fast oats", "instant oats", "one minute oats", "quick cooking oats", "thin rolled oats"]
1801	quince	["aromatic quince", "cooking quince", "cydonia", "golden apple", "quinces"]
1802	quince fruit	["cooking quince", "cydonia fruit", "golden quince", "pear quince", "portuguese quince"]
90	quinoa	["ancient grain quinoa", "mother grain", "quinoa grain", "red quinoa", "superfood quinoa", "tricolor quinoa", "white quinoa"]
1804	quinoa flour	["ancient grain flour", "gluten free quinoa flour", "ground quinoa", "milled quinoa", "quinoa powder"]
1805	quinoa milk	["ancient grain milk", "dairy free quinoa", "grain milk quinoa", "plant quinoa milk", "quinoa beverage"]
1806	quinoa seeds	["ancient quinoa", "mother grain", "quinoa grain", "red quinoa", "white quinoa"]
1807	rabbit	["bunny meat", "game rabbit", "rabbit legs", "rabbit meat", "whole rabbit"]
1808	rack of lamb	["8-bone rack", "crown roast", "frenched rack", "lamb rib rack", "lamb ribs"]
1809	raclette	["alpine raclette", "fondue cheese", "melting cheese", "raclette cheese", "swiss raclette"]
1810	radiatore	["little radiators", "nugget pasta", "radiator pasta", "ruffled pasta", "squat pasta"]
1811	radicchio	["chioggia", "italian chicory", "radicchio rosso", "red chicory", "red lettuce"]
1812	radish sprouts	["daikon sprouts", "kaiware", "radish microgreens", "radish shoots", "sprouted radish"]
1813	radishes	["button radishes", "globe radishes", "radish", "red radishes", "table radishes"]
1814	rainbow carrots	["colored carrot mix", "heirloom carrots mixed", "heritage carrot blend", "multicolor carrots", "tri color carrots"]
1815	rainbow cauliflower	["assorted cauliflower", "heirloom cauliflower mix", "mixed color cauliflower", "multicolor cauliflower", "tri color cauliflower"]
1816	rainbow chard	["bright lights chard", "colored chard", "five color silverbeet", "multi colored chard", "ornamental chard"]
1817	rainbow trout	["brook trout", "freshwater trout", "mountain trout", "pan trout", "trout"]
1818	rainier cherries	["blush cherries", "premium cherries", "rainier", "white cherries", "yellow cherries"]
1819	raisins	["dried grapes", "seedless raisins", "sultanas", "sun dried grapes", "thompson raisins"]
1820	rajma	["indian kidney beans", "kidney bean curry", "punjabi rajma", "rajma masala", "red bean curry"]
1821	rambai	["baccaurea", "rambi", "southeast asian fruit", "tampoi", "tropical rambai"]
1822	rambai fresh	["fresh baccaurea", "fresh rambi", "fresh southeast asian fruit", "fresh tampoi", "ripe rambai"]
1823	rambutan fresh	["fresh nephelium", "hairy lychee fresh", "indonesian rambutan", "malaysian rambutan", "tropical rambutan fresh"]
1824	rambutans	["chom chom", "hairy lychee", "nephelium", "rambutan", "tropical rambutan"]
1825	ramen noodles	["alkaline noodles", "asian wheat noodles", "chinese ramen", "fresh ramen", "instant ramen"]
1826	ranch dip mix	["dry ranch mix", "hidden valley packet", "ranch dip powder", "ranch packet", "ranch seasoning packet"]
1827	ranch dressing	["buttermilk ranch", "cool ranch", "hidden valley style", "ranch", "ranch dip"]
1828	ranch seasoning	["buttermilk ranch mix", "dry ranch", "ranch dressing mix", "ranch mix", "ranch spice blend"]
1829	ras el hanout	["baharat alternative", "head of shop spice", "moroccan spice blend", "north african blend", "ras al hanout"]
1830	raspberries	["bramble berries", "fresh raspberries", "raspberry", "red raspberries", "rubus"]
1831	raspberry seed oil	["berry seed oil", "omega raspberry", "raspberry kernel oil", "red raspberry oil", "rubus oil"]
1832	ratatouille vegetables	["french vegetable medley", "mediterranean vegetables", "provencal vegetables", "ratatouille mix", "summer vegetable mix"]
1833	rattlesnake beans	["dried rattlesnake", "heirloom beans", "pole beans dried", "speckled cranberry", "streaked beans"]
1834	ravioli	["cheese ravioli", "filled pasta", "italian ravioli", "square pasta", "stuffed pasta"]
1835	raw milk	["farm fresh milk", "straight from cow", "unpasteurized milk", "unprocessed milk", "whole raw milk"]
1836	raw sugar	["evaporated cane juice", "minimally processed sugar", "natural cane sugar", "organic raw sugar", "unrefined sugar"]
1837	razor clams	["atlantic jackknife", "bamboo clams", "jackknife clams", "siliqua", "straight razor clams"]
1838	razor shell	["bamboo clam meat", "jackknife clam", "razor clam meat", "razor fish", "spoot"]
1839	reblochon	["french reblochon", "savoie cheese", "soft french alpine", "tartiflette cheese", "washed reblochon"]
1840	red bananas	["crimson banana", "cuban red banana", "jamaican red banana", "red banana", "spanish red banana"]
1841	red beans	["dried red beans", "mexican red beans", "red chili beans", "small red beans", "texas red beans"]
1842	red bell peppers	["bell peppers red", "red bell pepper", "red capsicum", "red peppers", "red sweet peppers"]
1843	red cabbage	["blue cabbage", "braising cabbage", "purple cabbage", "red dutch cabbage", "red kraut"]
1844	red cargo rice	["brown red rice", "himalayan red alternative", "red jasmine rice", "thai red rice", "unpolished red thai"]
1845	red chard	["burgundy silverbeet", "crimson chard", "red stemmed chard", "rhubarb chard", "ruby chard"]
1846	red currants	["garden currants", "northern berries", "red currant", "redcurrants", "ribes rubrum"]
1847	red curry paste	["gaeng phed", "hot curry paste", "red chili paste curry", "spicy curry paste", "thai red curry"]
1848	red delicious apples	["classic red apples", "delicious apples", "red apples", "red delicious", "washington red"]
1849	red dragon fruit	["costa rica pitaya", "hylocereus", "magenta pitaya", "red flesh dragon", "red pitaya"]
1850	red fife wheat	["ancient wheat red", "canadian heritage wheat", "heirloom wheat berries", "heritage wheat", "landrace wheat"]
1851	red grapes	["crimson grapes", "flame grapes", "red globe", "red seedless grapes", "ruby grapes"]
1852	red kuri squash	["hokkaido pumpkin", "japanese squash red kuri", "onion squash", "orange hokkaido", "uchiki kuri"]
1853	red leaf lettuce	["lollo rosso", "oak leaf red", "red coral lettuce", "red leaf", "red lettuce"]
1854	red lentils	["egyptian lentils", "masoor dal", "orange lentils", "pink lentils", "split red lentils"]
1855	red miso	["aged miso", "aka miso", "dark miso", "salty miso", "strong miso"]
1856	red onions	["crimson onions", "purple onions", "red cooking onions", "red onion", "salad onions red"]
1857	red palm oil	["carotene palm oil", "orange palm oil", "unrefined palm oil", "virgin palm oil", "west african palm"]
1858	red plums	["crimson plums", "red plum", "red skin plums", "ruby plums", "santa rosa plums"]
1859	red potatoes	["new red potatoes", "red bliss potatoes", "red potato", "red-skinned potatoes", "round red potatoes"]
1860	red quinoa	["colored quinoa", "crimson quinoa", "heirloom quinoa", "red grain quinoa", "scarlet quinoa"]
1861	red radish sprouts	["crimson radish sprouts", "red kaiware", "red radish microgreens", "ruby radish sprouts", "scarlet radish shoots"]
1862	red rice	["bhutanese red rice", "camargue red rice", "cargo rice", "himalayan red rice", "wehani rice"]
1863	red rice camargue	["burgundy rice france", "camargue rice", "french red rice", "scarlet rice", "whole grain red rice"]
1864	red wine vinegar	["burgundy vinegar", "cabernet vinegar", "italian red vinegar", "red vinegar wine", "robust wine vinegar"]
1865	refined coconut oil	["cooking coconut oil", "deodorized coconut oil", "expeller pressed coconut", "neutral coconut oil", "rbd coconut"]
1866	refried beans	["canned refried", "frijoles refritos", "instant refried", "mashed beans", "mexican refried"]
1867	reindeer milk	["arctic milk", "caribou milk", "nordic milk", "rangifer milk", "sami milk"]
1868	remoulade	["cajun remoulade", "french remoulade", "louisiana remoulade", "seafood remoulade", "spicy mayo sauce"]
1869	rennet	["animal rennet", "cheese rennet", "coagulant", "microbial rennet", "vegetable rennet"]
36	currants	["zante currants", "black currants", "dried currants", "fresh currants", "red currants", "ribes", "white currants"]
1871	ribeye steak	["bone-in ribeye", "cowboy steak", "delmonico steak", "rib eye", "ribeye beef"]
1872	rice beans	["adzuki alternative", "chinese red beans", "dried rice beans", "mountain beans", "red beans small"]
1873	rice bran oil	["asian cooking oil", "high heat rice oil", "oryza oil", "refined rice bran", "rice oil"]
1874	rice cakes	["brown rice cakes", "lightly salted cakes", "plain rice cakes", "puffed rice cakes", "whole grain rice cakes"]
1875	rice flour	["glutinous rice flour alternative", "ground rice", "milled rice", "rice powder", "white rice flour"]
1876	rice milk	["dairy free rice", "plant rice milk", "rice beverage", "rice drink", "rice mylk"]
1877	rice noodles	["asian rice noodles", "banh pho", "pad thai noodles", "rice stick noodles", "rice vermicelli"]
1878	rice paper	["banh trang", "rice sheets", "spring roll wrappers", "summer roll wrappers", "vietnamese rice paper"]
1879	rice starch	["asian starch", "glutinous rice starch", "mochi starch", "rice flour starch", "sweet rice starch"]
1880	rice syrup	["asian rice syrup", "brown rice syrup", "maltose syrup", "rice malt syrup", "rice sweetener"]
1881	rice vermicelli	["bee hoon", "bun noodles", "rice sticks thin", "thin rice noodles", "vietnamese vermicelli"]
1882	rice vinegar	["asian vinegar", "japanese vinegar", "mild vinegar", "rice wine vinegar", "sushi vinegar"]
94	ricotta cheese	["fresh ricotta", "italian ricotta", "ricotta", "soft italian cheese", "whole milk ricotta"]
1884	ridge gourd	["angled luffa", "chinese okra", "luffa", "ridged loofah", "sponge gourd"]
1885	rigatoni	["large penne", "macaroni large", "ridged tubes", "rigate tubes", "tube pasta ridged"]
1886	ripe plantains	["black plantains", "maduro", "ripe cooking bananas", "sweet plantains", "yellow plantains"]
1887	ritz crackers	["butter crackers", "buttery crackers", "flaky crackers", "round crackers", "snack crackers buttery"]
1888	roasted chestnuts	["cooked chestnuts", "hot chestnuts", "jarred chestnuts", "peeled chestnuts", "ready to eat chestnuts"]
1889	roasted chickpeas	["chickpea snacks", "crispy chickpeas", "crunchy chickpeas", "roasted garbanzo beans", "savory chickpeas"]
1890	roasted garlic	["caramelized garlic", "jarred roasted garlic", "oven roasted garlic", "roasted garlic cloves", "soft garlic"]
1891	roasted pumpkin seeds	["crunchy pepitas", "roasted squash seeds", "salted pumpkin seeds", "spiced pumpkin seeds", "toasted pepitas"]
1892	roasted red peppers	["fire roasted peppers", "jarred roasted peppers", "peeled roasted peppers", "pimientos", "roasted bell peppers"]
1893	roasting vegetables	["mediterranean roasting mix", "oven vegetables", "roasting blend", "root vegetable mix", "winter vegetables"]
1894	robiola	["fresh robiola", "lombardy cheese", "mixed milk cheese", "piedmont cheese", "soft italian cheese"]
1895	rock shrimp	["florida shrimp", "mini lobster", "rock prawns", "small lobster taste", "stone shrimp"]
1896	rocoto pepper	["apple pepper", "canario pepper", "locoto", "manzano pepper", "tree chili"]
1897	rolled oats	["flaked oats", "oatmeal", "old fashioned oats", "porridge oats", "regular oats"]
1898	roma tomatoes	["cooking tomatoes", "italian tomatoes", "paste tomatoes", "plum tomatoes", "roma tomato"]
1899	romaine lettuce	["cos", "cos lettuce", "long lettuce", "romaine", "roman lettuce"]
1900	romanesco broccoli	["coral broccoli", "fractal broccoli", "roman cauliflower", "romanesco", "romanesque cauliflower"]
1901	romano beans	["flat beans", "italian green beans", "italian pole beans", "romano pole beans", "wide beans"]
1902	romano cheese	["domestic romano", "grating romano", "hard romano", "italian style romano", "pecorino style"]
1903	roquefort	["authentic roquefort", "cave aged blue", "french blue cheese", "roquefort aoc", "sheep blue cheese"]
1904	rose petals	["culinary roses", "dried rose petals", "edible rose petals", "fragrant petals", "rosa petals"]
1905	rose water	["floral water rose", "gulab jal", "rose distillate", "rose essence", "rosewater"]
1906	rosemary oil	["cooking rosemary oil", "herbal rosemary oil", "mediterranean rosemary", "needle herb oil", "rosmarinus oil"]
1907	rotini	["corkscrew pasta", "fusilli short", "rotelle", "spiral pasta", "twisted pasta"]
1908	rowan berries	["dogberry", "mountain ash berry", "quickbeam berry", "sorbus", "witchwood berry"]
1909	rowanberries	["mountain ash fruit", "quickbeam fruit", "rowan fruit", "sorb", "witchen fruit"]
1910	royal jasmine rice	["fragrant jasmine premium", "premium jasmine", "thai hom mali", "top grade jasmine", "white jasmine premium"]
1911	royal rice	["black rice premium", "emperor rice", "forbidden rice grade", "purple rice premium", "rare black rice"]
1912	ruby red grapefruit	["pink grapefruit", "red grapefruit", "ruby red", "sweet grapefruit", "texas ruby"]
1913	russet potatoes	["baking potatoes", "idaho potatoes", "russet burbank", "russet potato", "russets"]
1914	russian dressing	["pink russian", "red russian", "reuben sauce", "russian mayo", "spicy thousand island"]
1915	rutabaga	["neep", "russian turnip", "swede", "swedish turnip", "yellow turnip"]
1916	rye berries	["cereal rye", "rye grain", "rye kernels", "unprocessed rye", "whole rye"]
1917	rye bread	["caraway rye", "dark rye bread", "deli rye", "jewish rye", "light rye bread"]
1918	rye flakes	["cracked rye", "flaked rye", "rolled rye", "rye cereal", "rye oats alternative"]
1919	rye flour	["dark rye flour", "light rye flour", "medium rye flour", "pumpernickel flour", "stone ground rye"]
1920	saba bananas	["cardaba", "cooking bananas philippine", "filipino cooking banana", "saba plantain", "square bananas philippine"]
1921	sacha inchi oil	["amazon oil", "inca peanut oil", "mountain peanut oil", "plukenetia oil", "sacha inchi seed"]
1922	sacha inchi seeds	["amazon peanuts", "inca peanuts", "mountain peanuts", "sacha seeds", "star seeds"]
1923	sadri rice	["caspian rice", "iranian sadri", "persian short grain", "sadri basmati", "shiraz rice"]
1924	safflower oil	["cooking safflower", "high oleic safflower", "neutral safflower oil", "refined safflower", "safflower seed oil"]
1925	saffron threads	["crocus threads", "kesar", "red gold", "saffron", "spanish saffron"]
1926	sage oil	["common sage oil", "cooking sage oil", "garden sage oil", "mediterranean sage", "salvia oil"]
1927	salad mix	["field greens", "mesclun", "mixed greens", "salad blend", "spring mix"]
1928	salad turnips	["baby white turnips", "hakurei turnips", "japanese turnips", "tokyo turnips", "white salad turnips"]
1929	salak	["indonesian fruit", "salacca", "snake fruit", "snake skin fruit", "zalacca"]
1930	salak fresh	["fresh indonesian fruit", "fresh salacca", "fresh snake fruit", "fresh zalacca", "ripe salak"]
1931	salmon canned	["alaska salmon canned", "canned pink salmon", "canned red salmon", "sockeye canned", "wild salmon canned"]
1932	salmon fillet	["atlantic salmon", "fresh salmon", "salmon", "salmon portions", "salmon steak"]
1933	salmon oil	["alaskan salmon oil", "fish oil salmon", "omega 3 salmon", "pink salmon oil", "wild salmon oil"]
1934	salmonberries	["alaskan berry", "coastal berry", "pacific berry", "rubus spectabilis", "salmonberry"]
96	salsa	["chunky salsa", "jarred salsa", "medium salsa", "mild salsa", "pico de gallo", "salsa fresca", "tomato salsa", "tomato salsa mild"]
1936	salsa roja	["cooked salsa", "mexican red sauce", "red salsa", "salsa roja mexican", "tomato salsa"]
1937	salsa verde	["green salsa", "mexican green sauce", "roasted tomatillo salsa", "salsa verde mexican", "tomatillo salsa"]
1938	salsify	["goats beard", "oyster plant", "tragopogon", "vegetable oyster", "white salsify"]
97	salt	["common salt", "cooking salt", "fine salt", "iodized salt", "kosher salt", "sea salt", "table salt"]
1940	salted butter	["butter salted", "regular butter", "salted churned butter", "sweet cream butter salted", "table butter"]
1941	salted fish	["bacalao", "baccala", "preserved fish", "salt cod", "salt cured fish"]
1942	sambal oelek	["asian chili sambal", "chili paste", "ground chili paste", "indonesian chili sauce", "sambal"]
1943	san marzano tomatoes	["authentic san marzano", "canning tomatoes italian", "dop tomatoes", "italian plum", "paste tomatoes san marzano"]
1944	sanding sugar	["coarse sugar colored", "crystal sugar", "decorating sugar", "large crystal decorating", "sparkling sugar"]
1945	sanding sugar colored	["coarse colored sugar", "colored sanding", "crystal sugar colored", "decorating sugar rainbow", "sparkling colored sugar"]
1946	sandwich bread	["pullman bread", "sliced sandwich bread", "soft bread", "wheat sandwich bread", "white sandwich bread"]
1947	sansho pepper	["japanese pepper", "japanese peppercorn", "mountain pepper", "prickly ash japanese", "szechuan alternative japanese"]
1948	santa claus melon	["christmas melon", "piel de sapo", "spanish melon", "toad skin melon", "winter melon santa"]
1949	sapodilla	["chikoo", "manilkara", "naseberry", "sapota", "tropical sapodilla"]
1950	sapodilla fresh	["fresh chikoo", "fresh manilkara", "fresh naseberry", "fresh sapota", "ripe sapodilla"]
1951	sapote fresh	["fresh black sapote", "fresh chocolate pudding fruit", "fresh diospyros", "fresh zapote negro", "ripe sapote"]
1952	sardines	["brisling", "canned sardines", "pilchard", "sardine", "small fish"]
1953	sardines canned	["canned sardines in oil", "canned sardines in water", "packed sardines", "sardine fillets", "small fish canned"]
1954	satsuma oranges	["japanese oranges", "mikan", "satsumas", "seedless satsumas", "unshiu"]
1955	sauerkraut	["fermented cabbage", "german sauerkraut", "lacto fermented cabbage", "pickled cabbage", "sour cabbage"]
1956	sausages	["bangers", "breakfast sausage", "fresh sausage", "pork sausage", "sausage links"]
1957	savoy cabbage	["crinkled cabbage", "curly cabbage", "savoy", "savoy leaf cabbage", "winter cabbage"]
1958	sazon seasoning	["annatto seasoning", "goya sazon style", "latin color seasoning", "sazon spice", "spanish seasoning"]
1959	scallops	["bay scallops", "diver scallops", "fresh scallops", "sea scallops", "seared scallops"]
1960	scamorza	["italian pasta filata", "pear shaped cheese", "smoked scamorza", "southern italian cheese", "stretched curd smoked"]
1961	scarlet runner beans	["ayocote beans", "dutch runner beans", "multiflora beans", "painted lady beans", "runner beans dried"]
1962	schisandra berries	["chinese magnolia", "five flavor berry", "magnolia vine", "schisandra chinensis", "wu wei zi"]
1963	scones	["british scones", "cream scones", "english scones", "fruit scones", "tea scones"]
1964	scorzonera	["black oyster plant", "black salsify", "serpent root", "spanish salsify", "viper grass"]
1965	scotch bonnet	["bahamian pepper", "bonney pepper", "caribbean pepper", "jamaican pepper", "trinidad pepper"]
1966	sea bass	["bass fillet", "branzino", "european sea bass", "loup de mer", "mediterranean bass"]
1967	sea beans	["glasswort", "pickleweed", "salicornia", "samphire", "sea asparagus"]
1968	sea buckthorn	["hippophae", "sallow thorn", "sandthorn", "seaberry", "siberian pineapple"]
1969	sea cucumber	["beche-de-mer", "holothurian", "sandfish", "sea slug", "trepang"]
1970	sea grapes	["caulerpa", "green caviar", "ocean grapes", "sea pearls", "umibudo"]
1971	sea lettuce	["edible ulva", "green laver", "green seaweed", "sea salad", "ulva"]
1972	sea palm	["brown kelp palm", "edible sea palm", "kelp palm", "pacific sea palm", "postelsia"]
1973	sea salt	["celtic salt", "coarse sea salt", "grey salt", "ocean salt", "sel gris"]
1974	sea scallops	["atlantic scallops", "diver scallops", "jumbo scallops", "large scallops", "searing scallops"]
1975	sea urchin	["echinus", "sea hedgehog", "sea urchin roe", "uni", "urchin gonads"]
1976	sea vegetables	["aquatic vegetables", "edible seaweed", "marine vegetables", "ocean vegetables", "sea greens"]
1977	seasoned salt	["all purpose seasoning salt", "flavored salt", "lawrys seasoned salt", "season salt", "table seasoning"]
1978	seaweed snacks	["crispy nori", "korean seaweed snacks", "nori sheets roasted", "roasted seaweed", "salted seaweed"]
1979	sechium	["chayote vegetable", "chocho", "mango squash", "mirliton squash", "vegetable pear raw"]
1980	seckel pears	["baby pears", "seckel", "snack pears", "sugar pears", "tiny pears"]
1981	seed butter blend	["allergy friendly butter", "mixed seed butter", "nut free seed butter", "omega seed butter", "sunflower seed blend"]
1982	seedless watermelon	["convenient watermelon", "easy watermelon", "hybrid watermelon", "modern watermelon", "seedless watermelons"]
1983	self rising flour	["biscuit flour leavened", "leavened flour", "self raising flour", "self-rising flour", "southern flour"]
1984	semi-sweet chocolate	["52% chocolate", "baking chocolate semi-sweet", "bittersweet alternative", "dark baking chocolate", "standard baking chocolate"]
1985	semi-sweet chocolate chips	["cookie chips", "dark baking chips", "nestle tollhouse", "semisweet chips", "standard chocolate chips"]
99	semolina	["coarse semolina", "cream of wheat", "cream of wheat base", "durum wheat flour", "durum wheat semolina", "fine semolina", "pasta flour", "semolina flour"]
1987	serrano ham	["cured spanish ham", "dry ham spain", "jamon serrano", "mountain ham", "spanish ham"]
1988	serrano peppers	["fresh serranos", "serrano chiles", "serrano chilies", "serrano pepper", "serranos"]
1989	serviceberries	["amelanchier", "juneberry", "saskatoon berry", "serviceberry", "shadbush"]
1990	serviceberry fruit	["amelanchier fruit", "juneberry fruit", "saskatoon fruit", "shadbush fruit", "sugar pear"]
1991	sesame oil	["asian sesame oil", "chinese sesame oil", "dark sesame oil", "roasted sesame", "toasted sesame oil"]
1992	sesame paste oil	["asian tahini oil", "ground sesame oil", "middle eastern sesame", "sesame butter oil", "tahini oil"]
1993	sesame seeds	["hulled sesame", "natural sesame", "raw sesame", "toasted sesame seeds", "white sesame seeds"]
1994	shacha sauce	["bullhead sauce", "chinese barbecue sauce", "seafood bbq sauce", "sha cha jiang", "taiwanese bbq sauce"]
1995	shallots	["asian shallots", "eschalots", "french shallots", "golden shallots", "shallot"]
1996	sharp cheddar	["aged cheddar", "bitey cheddar", "extra sharp cheddar", "mature cheddar", "old cheddar"]
1997	shea butter	["african butter tree", "cooking shea butter", "karite butter", "shea oil", "vitellaria"]
1998	shea nut	["african butter nut", "buttery nut", "karite nut", "shea seed", "vitellaria seed"]
1999	sheep cheese soft	["creamy sheep cheese", "ewes cheese soft", "fresh sheep cheese", "sheep milk soft cheese", "soft ovine cheese"]
2000	sheep milk	["ewes milk", "fresh sheep milk", "ovine milk", "raw sheep milk", "sheep whole milk"]
2001	sheep yogurt	["ewes yogurt", "greek sheep yogurt", "ovine yogurt", "sheep milk yogurt", "sheeps milk yogurt"]
2002	shells	["conchiglie", "medium shells", "pasta shells", "shell pasta", "small shells"]
2003	sherry vinegar	["aged sherry vinegar", "fortified wine vinegar", "jerez vinegar", "spanish vinegar", "vinagre de jerez"]
2004	shiitake mushrooms	["black forest mushroom", "chinese black mushroom", "oakwood mushroom", "shiitake", "shitake"]
2005	shirataki noodles	["glucomannan noodles", "konjac noodles", "miracle noodles", "yam noodles", "zero calorie noodles"]
2006	shishito peppers	["asian sweet peppers", "japanese peppers", "shishito chilies", "sweet japanese peppers", "wrinkled peppers"]
2007	shiso leaves	["beefsteak plant", "japanese basil", "ooba", "perilla leaves", "shiso perilla"]
2008	short ribs	["beef short ribs", "braising ribs", "english cut ribs", "flanken ribs", "korean short ribs"]
2009	shortening	["baking shortening", "crisco", "hydrogenated vegetable oil", "solid shortening", "vegetable shortening"]
2010	shredded coconut	["baking coconut", "coconut flakes", "desiccated coconut", "dried coconut", "sweetened shredded coconut"]
100	shrimp	["fresh shrimp", "gulf shrimp", "jumbo shrimp", "pink shrimp", "prawns", "shell-on shrimp", "shellfish"]
2012	sichuan peppercorns	["chinese pepper", "huajiao", "japanese pepper alternative", "prickly ash", "szechuan pepper"]
2013	silken tofu	["japanese tofu", "kinugoshi", "silky tofu", "smooth tofu", "soft tofu"]
2014	simple syrup	["bar syrup", "cocktail syrup", "dissolved sugar", "one to one syrup", "sugar syrup"]
2015	single cream	["18% cream uk", "british light cream", "coffee cream british", "pouring cream", "thin cream"]
2016	sirene	["balkan feta", "brined balkan cheese", "bulgarian white cheese", "sheep sirene", "white cheese bulgaria"]
2017	sirloin steak	["london broil", "rump steak", "sirloin beef", "sirloin tip", "top sirloin"]
2018	skim milk	["0% milk", "fat free milk", "no fat milk", "nonfat milk", "skimmed milk"]
2019	skirret	["crummock", "sium sisarum", "suikerwortel", "sweet root skirret", "water parsnip root"]
2020	skirt steak	["arrachera", "beef skirt", "fajita meat", "inside skirt", "outside skirt"]
2021	sliced almonds	["almond slices", "blanched sliced", "flaked almonds", "slivered almonds", "thin almonds"]
2022	slivered almonds	["almond slivers", "blanched slivered", "julienned almonds", "matchstick almonds", "thin cut almonds"]
2023	sloes	["blackthorn", "hedge plum", "prunus spinosa", "sloe berry", "wild plum"]
2024	sloppy joe seasoning	["instant sloppy joe", "joe seasoning packet", "manwich alternative", "sandwich seasoning", "sloppy joe mix"]
2025	smetana	["cultured cream eastern", "eastern european sour cream", "russian sour cream", "slavic smetana", "thin sour cream"]
2026	smoked cheddar	["applewood smoked cheddar", "flavored cheddar", "hickory cheddar", "smoked cheese cheddar", "wood smoked cheddar"]
2027	smoked gouda	["applewood gouda", "flavored gouda", "hickory gouda", "smoked dutch cheese", "wood smoked gouda"]
2028	smoked oil	["applewood oil", "bbq smoke oil", "hickory oil", "liquid smoke oil", "mesquite oil"]
2029	smoked paprika	["hot smoked paprika", "pimenton", "smoked spanish pepper", "spanish smoked paprika", "sweet smoked paprika"]
2030	smoked provolone	["aged smoked provolone", "hickory provolone", "provolone piccante", "sharp smoked provolone", "smoked italian cheese"]
2031	smooth luffa	["chinese gourd", "dishcloth gourd", "silk squash", "smooth loofah", "vegetable gourd"]
2032	snake gourd	["chichinda", "long white gourd", "serpent gourd", "twisted gourd", "viper gourd"]
2033	snapper	["lane snapper", "mangrove snapper", "red snapper", "snapper fillet", "yellowtail snapper"]
2034	snipe	["common snipe", "gallinago", "game bird snipe", "jacksnipe", "wilson snipe"]
2035	snow crab	["opilio crab", "queen crab", "snow crab legs", "spider crab", "tanner crab"]
2036	snow peas	["chinese pea pods", "chinese snow peas", "edible pod peas", "flat pea pods", "mangetout"]
2037	soba noodles	["brown noodles", "buckwheat noodles", "cold noodles", "healthy noodles", "japanese soba"]
2038	soba noodles 100 percent	["authentic soba", "juwari soba", "pure buckwheat noodles", "traditional soba", "wheat free soba"]
2039	sockeye salmon	["alaskan salmon", "blueback salmon", "red salmon", "sockeye", "wild sockeye"]
2040	sodium aluminum sulfate	["baking powder ingredient", "commercial leavener", "double acting agent", "leavening acid", "sas"]
2041	sofrito vegetables	["caribbean sofrito", "latin cooking base", "recaito vegetables", "sofrito mix", "spanish sofrito"]
2042	soft shell crab	["hotel crab", "molting blue crab", "peeler crab", "shed crab", "softshell crab"]
2043	soldier beans	["dried soldier", "heirloom soldier", "johnson beans", "new england beans", "white beans marked"]
2044	sole	["dover sole", "english sole", "lemon sole", "petrale sole", "rex sole"]
2045	somen noodles	["cold somen", "delicate noodles", "japanese thin noodles", "summer noodles", "white wheat noodles"]
2046	sorghum	["broomcorn", "gluten free sorghum", "grain sorghum", "jowar", "milo"]
2047	sorghum syrup	["grain syrup", "sorghum cane syrup", "sorghum molasses", "southern syrup", "sweet sorghum"]
2048	sorrel leaves	["dock", "garden sorrel", "sorrel", "sour grass", "spinach dock"]
101	sour cream	["creme fraiche alternative", "crème fraîche", "cultured cream", "cultured sour cream", "dairy sour cream", "fresh sour cream", "soured cream"]
2050	sour cream powder	["dehydrated sour cream", "dried sour cream", "instant sour cream", "powdered sour cream", "sour cream mix"]
2051	sourdough bread	["artisan sourdough", "crusty sourdough", "san francisco sourdough", "sourdough loaf", "tangy bread"]
2052	soursop	["annona", "custard apple soursop", "graviola", "guanabana", "prickly custard"]
2053	soursop fresh	["fresh annona", "fresh graviola", "fresh guanabana", "fresh prickly custard", "ripe soursop"]
2054	soy curls	["butler soy curls", "dried soy strips", "rehydrating soy", "textured soy strips", "whole soybean strips"]
2055	soy flour	["defatted soy flour", "full fat soy flour", "kinako", "roasted soy flour", "soya flour"]
2056	soy lecithin	["emulsifier soy", "liquid lecithin", "phospholipids", "soy fat", "soya lecithin"]
2057	soy milk	["dairy free milk soy", "plant milk soy", "soy beverage", "soya milk", "soybean milk"]
2058	soy nuggets	["meal maker", "nutri nuggets", "soy chunks", "soya chunks", "textured soy nuggets"]
2059	soy protein	["isolated soy protein", "soy concentrate", "soy protein isolate", "soya protein powder", "textured soy protein"]
102	soy sauce	["dark soy sauce", "light soy sauce", "liquid aminos alternative", "shoyu", "soya sauce", "tamari"]
2061	soy yogurt	["cultured soy milk", "dairy free yogurt soy", "soy yoghurt", "soya yogurt", "vegan yogurt soy"]
2062	soybean oil	["glycine oil", "refined soy oil", "soy cooking oil", "soya oil", "vegetable soybean"]
2063	soybeans	["dried soybeans", "edamame dried", "glycine max", "soya beans", "yellow soybeans"]
2064	spaghetti	["italian spaghetti", "long pasta", "number 5 pasta", "spaghetti pasta", "thin spaghetti"]
2065	spaghetti squash	["noodle squash", "spaghetti marrow", "squash spaghetti", "vegetable spaghetti", "winter squash spaghetti"]
2066	spelt	["ancient spelt", "dinkel wheat", "hulled wheat", "spelt berries", "whole spelt"]
2067	spiced nuts	["cajun nuts", "curry nuts", "roasted spiced nuts", "savory nuts", "seasoned mixed nuts"]
2068	spicy brown mustard	["brown mustard", "deli mustard", "gulden mustard style", "hot mustard", "sandwich mustard"]
2069	spider crab	["european spider crab", "japanese spider crab", "maja squinado", "snow crab alternative", "spiny spider crab"]
2070	spinach leaves	["baby spinach", "english spinach", "fresh spinach", "leaf spinach", "spinach"]
2071	spirulina	["arthrospira", "blue green algae", "dried spirulina", "spirulina powder", "superfood algae"]
2072	split peas	["dal peas", "dried split peas", "green split peas", "soup peas", "yellow split peas"]
2073	spot prawns	["alaskan prawns", "pacific spot prawns", "spot shrimp", "sushi prawns", "sweet prawns"]
2074	spray oil	["aerosol oil", "baking spray", "cooking spray", "non stick spray", "pam"]
2075	sprinkles	["chocolate sprinkles", "hundreds and thousands", "jimmies", "nonpareils", "rainbow sprinkles"]
2076	sprouted nuts	["activated nuts", "enzyme active nuts", "germinated nuts", "raw sprouted", "soaked nuts dried"]
2077	squab	["domestic pigeon", "pigeon meat", "wild pigeon", "wood pigeon", "young pigeon"]
2078	squash blossoms	["courgette flowers", "cucurbit flowers", "marrow flowers", "pumpkin blossoms", "zucchini flowers"]
2079	squid	["calamari", "fresh squid", "squid tentacles", "squid tubes", "whole squid"]
2080	squid ink	["black pasta ink", "cuttlefish ink", "nero di seppia", "pasta sauce ink", "sepia ink"]
2081	sriracha	["huy fong sriracha", "red sriracha", "rooster sauce", "sriracha chili sauce", "thai hot sauce"]
2082	sriracha mayo	["hot mayo", "rooster mayo", "spicy mayo asian", "sriracha aioli", "thai mayo"]
2083	sriracha oil	["asian sriracha oil", "garlic chili oil", "red hot oil", "rooster sauce oil", "thai hot sauce oil"]
2084	star anise	["badiane", "chinese star anise", "eight horn spice", "star aniseed", "八角"]
2085	starfruit	["bilimbi", "carambola", "five finger fruit", "star fruit", "tropical starfruit"]
2086	steak seasoning	["beef seasoning", "grilling steak spice", "montreal steak seasoning", "steak rub", "steakhouse seasoning"]
2087	steel cut oats	["coarse oats", "irish oats", "oat groats cut", "pinhead oats", "scottish oats"]
2088	steelhead trout	["anadromous trout", "rainbow trout ocean", "sea trout", "steelhead", "steelhead salmon"]
2089	stew meat	["beef chunks", "beef stew meat", "beef tips", "braising beef", "cubed beef"]
2090	sticky rice	["glutinous rice", "mochi rice", "pearl rice", "sweet rice", "thai sticky rice"]
2091	stilton	["blue stilton", "british stilton", "crumbly blue", "derbyshire stilton", "english blue cheese"]
2092	stir fry vegetables	["asian vegetable mix", "chinese vegetable mix", "oriental vegetables", "stir fry blend", "wok vegetables"]
2093	stockfish	["air dried fish", "clipfish", "dried cod", "hardfisk", "unsalted dried cod"]
2094	stone crab claws	["cooked claws", "crab claws", "florida stone crab", "menippe", "stone crab"]
2095	stracchino	["crescenza", "fresh stracchino", "lombardy soft cheese", "soft spreadable italian", "tired cow cheese"]
2096	straw mushrooms	["chinese mushroom", "grass mushroom", "paddy straw mushroom", "padi straw mushroom", "volvariella"]
2097	strawberries	["fresh strawberries", "garden strawberries", "june berries", "red berries", "strawberry"]
2098	strawberries fresh	["juicy strawberries", "local strawberries", "premium strawberries", "ripe strawberries", "sweet strawberries"]
2099	string cheese	["cheese sticks", "mozzarella sticks", "pull apart cheese", "snack cheese", "string mozzarella"]
2100	string cheese braided	["armenian cheese", "braided mozzarella", "mediterranean braid", "middle eastern string", "syrian cheese"]
2101	string cheese mozzarella	["akkawi alternative", "armenian string cheese", "braided cheese", "middle eastern string", "syrian string cheese"]
2102	striped bass	["atlantic striped bass", "linesides", "rockfish", "striper", "wild bass"]
2103	strudel	["apple strudel", "flaky strudel", "fruit strudel", "german strudel", "layered pastry"]
2104	stuffing mix	["bread stuffing", "herb stuffing mix", "seasoned stuffing", "stovetop stuffing", "turkey stuffing"]
2105	succotash mix	["corn and lima beans", "corn bean mix", "southern succotash", "succotash blend", "summer succotash"]
2106	sugar apple	["annona squamosa", "atis", "custard apple sweet", "sitaphal", "sweetsop"]
2107	sugar pumpkin	["baking pumpkin", "new england pie pumpkin", "pie pumpkin small", "sugar pie pumpkin", "sweet pumpkin"]
2108	sugar snap peas	["mangetout peas", "snap peas", "snapping peas", "sugar peas", "sugar snaps"]
2109	sumac	["ground sumac", "sicilian sumac", "sour spice", "sumac powder", "sumaq"]
2110	sun dried tomato pesto	["dried tomato sauce", "mediterranean pesto", "red pesto", "rosso pesto", "tomato pesto"]
2111	sun dried tomatoes	["dehydrated tomatoes", "dried tomatoes", "julienned sun dried", "sundried tomatoes", "tomato halves dried"]
2112	sun dried tomatoes in oil	["italian sundried", "jarred sundried tomatoes", "marinated sundried tomatoes", "oil packed tomatoes", "preserved sun dried tomatoes"]
2113	sunchoke flowers	["edible flowers artichoke", "helianthus flowers", "jerusalem artichoke blooms", "sunroot flowers", "topinambur flowers"]
2114	sunflower oil	["cooking sunflower oil", "golden sunflower oil", "light sunflower", "refined sunflower", "sunflower seed oil"]
2115	sunflower seed butter	["nut free butter alternative", "seed butter", "sun butter", "sunbutter", "sunflower butter"]
2116	sunflower seeds	["hulled sunflower", "raw sunflower kernels", "roasted sunflower seeds", "shelled sunflower seeds", "sunflower kernels"]
2117	sunflower sprouts	["sprouted sunflower", "sun sprouts", "sunflower greens", "sunflower microgreens", "sunflower shoots"]
2118	sungold tomatoes	["golden cherry", "hybrid cherry orange", "orange cherry", "super sweet cherry", "tangerine tomatoes"]
2119	superfood greens	["health greens", "kale spinach blend", "nutrient greens", "power greens", "super greens mix"]
2120	surf clams	["atlantic surf clams", "bar clams", "sea clams", "skimmer clams", "spisula"]
2121	sushi rice	["calrose rice", "japanese rice", "shari rice", "short grain rice", "sticky rice japanese"]
2122	sweet and sour sauce	["asian sweet sour", "chinese sweet sour", "pineapple sauce", "red sweet sour", "take out sauce"]
2123	sweet baby rays	["classic bbq", "molasses bbq", "sweet bbq sauce", "sweet rays style", "thick barbecue sauce"]
2124	sweet chili sauce	["asian sweet chili", "chili jam", "mae ploy style", "red sweet chili", "thai sweet chili"]
2125	sweet onions	["candy onions", "maui onions", "sweet yellow onions", "vidalia onions", "walla walla onions"]
2126	sweet peppers	["bull horn peppers", "corno di toro", "jimmy nardello peppers", "marconi peppers", "sweet italian horn"]
2127	sweet pickles	["bread and butter pickles", "candied pickles", "hamburger pickles", "sugar pickles", "sweet cucumber chips"]
2128	sweet potato leaves	["camote tops", "potato vine leaves", "sweet potato greens", "tropical spinach", "yam leaves"]
2129	sweet potato noodles	["dangmyeon", "japchae noodles", "korean vermicelli", "purple noodles", "sweet potato glass noodles"]
41	fish sauce	["asian fish sauce", "anchovy sauce asian", "fish soy sauce", "nam pla", "nuoc mam", "patis"]
2131	sweetbreads	["lamb sweetbreads", "pancreas offal", "ris de veau", "thymus gland", "veal sweetbreads"]
2132	sweetened condensed milk	["canned sweet milk", "condensed milk sugar", "condensed milk sweetened", "eagle brand milk", "thick sweet milk"]
2133	sweetened shredded coconut	["angel flake coconut", "baker coconut sweetened", "moist coconut", "sugar coconut", "sweet coconut"]
2134	swiss chard	["chard", "leaf beet", "rainbow chard", "seakale beet", "silverbeet"]
2135	swiss cheese	["alpine cheese", "baby swiss", "emmental", "hole cheese", "swiss emmental"]
2136	sword beans	["canavalia", "jack beans", "knife beans", "machete beans", "tropical beans"]
2137	swordfish steak	["broadbill", "mekajiki", "steak fish", "swordfish", "swordfish fillet"]
2138	t-bone steak	["beef t-bone", "loin steak with bone", "porterhouse steak", "strip and tenderloin", "t bone"]
2139	tabasco sauce	["louisiana tabasco", "original hot sauce", "red tabasco", "tabasco brand", "tabasco pepper sauce"]
2140	taco sauce	["hot taco sauce", "mexican taco sauce", "mild taco sauce", "ortega style sauce", "tex mex sauce"]
2141	taco seasoning	["fajita seasoning", "mexican seasoning", "taco blend", "taco spice mix", "tex mex seasoning"]
2142	taco seasoning mix	["instant taco seasoning", "mexican seasoning packet", "mild taco mix", "ortega taco seasoning", "taco spice packet"]
105	taco shells	["corn taco shells", "crispy taco shells", "crunchy taco shells", "hard taco shells", "stand and stuff shells", "taco shell"]
2144	tagliatelle	["bolognese pasta", "flat egg noodles", "italian egg pasta", "narrow fettuccine", "ribbon noodles"]
106	tahini	["ground sesame", "middle eastern tahini", "sesame butter", "sesame paste", "tahina", "tahini paste"]
2146	tahini paste	["ground sesame paste", "middle eastern tahini", "raw tahini", "sesame butter", "sesame tahini"]
2147	takoyaki sauce	["brown takoyaki", "japanese takoyaki", "octopus ball sauce", "osaka takoyaki sauce", "thick sauce takoyaki"]
2148	taleggio	["italian taleggio", "smelly cheese mild", "soft italian cheese", "stinky soft cheese", "washed rind"]
2149	tallow beef	["beef dripping rendered", "cooking tallow premium", "grass fed tallow", "prime beef tallow", "wagyu tallow"]
2150	tamari	["dark tamari", "gluten free soy sauce", "japanese tamari", "tamari soy sauce", "wheat free soy"]
2151	tamari sauce	["dark tamari", "gluten free tamari", "japanese tamari", "tamari soy sauce", "wheat free soy sauce"]
2152	tamarind	["imli", "indian date", "tamarind pods", "tamarindus", "tropical tamarind"]
2153	tamarind chutney	["date tamarind chutney", "imli chutney", "indian tamarind", "sweet tamarind sauce", "tangy tamarind"]
2154	tangelos	["honeybells", "minneola tangelos", "orlando tangelos", "tangerine grapefruit", "ugli fruit tangelo"]
2155	tangerines	["dancy tangerines", "honey tangerines", "mandarin tangerines", "tangelo", "tangerine"]
2156	tapatio	["guadalajara sauce", "mexican tapatio", "mild mexican sauce", "red tapatio", "tapatio hot sauce"]
2157	tapioca flour	["brazilian arrowroot", "cassava flour", "manioc starch", "tapioca starch", "yuca starch"]
2158	tapioca starch	["cassava starch", "manioc flour", "tapioca flour", "tapioca powder", "yuca starch"]
2159	taro root	["cocoyam", "dasheen", "eddo", "elephant ear", "taro"]
2160	tartar sauce	["fish sauce tartar", "pickle mayo", "remoulade alternative", "seafood sauce", "tartare sauce"]
2161	tasmanian pepper	["australian pepper", "mountain pepper", "native pepper", "pepperberry", "tasmannia"]
2162	tatsoi	["asian spinach", "flat cabbage", "rosette bok choy", "spinach mustard", "spoon mustard"]
2163	tayberries	["blackberry hybrid tayberry", "medana berry", "scottish berry", "tay valley berry", "tayberry"]
2164	tea bags	["black tea bags", "green tea bags", "herbal tea", "individual tea bags", "tea sachets"]
2165	teff	["ancient teff", "ethiopian grain", "lovegrass seed", "smallest grain", "tiny grain"]
2166	teleme	["california cheese", "monastery cheese west", "rice flour cheese", "soft teleme", "teleme cheese"]
2167	tempeh	["cultured soybeans", "fermented soybeans", "indonesian tempeh", "soybean cake", "tempeh block"]
2168	tempeh bacon	["fakin bacon", "marinated tempeh", "smoky tempeh", "tempeh strips", "vegan bacon"]
2169	tepary beans	["desert beans", "dried tepary", "drought beans", "native american beans", "southwestern beans"]
2170	teriyaki marinade mix	["asian marinade mix", "dry teriyaki mix", "instant teriyaki seasoning", "kikkoman style mix", "teriyaki packet"]
2171	teriyaki sauce	["asian teriyaki", "japanese barbecue sauce", "sweet soy glaze", "teriyaki glaze", "teriyaki marinade"]
2172	texas pete	["carolina hot sauce", "mild hot sauce", "red pepper texas", "southern texas pete", "texas pete hot sauce"]
2173	textured vegetable protein	["defatted soy flour", "soy meat", "textured soy protein", "tsp", "tvp"]
2175	thai bird chili	["birds eye thai", "prik kee noo suan", "small thai chili", "super hot thai", "tiny thai pepper"]
2176	thai chilies	["bird chiles", "birds eye chili", "prik kee noo", "thai chili peppers", "thai hot peppers"]
2177	thick cut bacon	["butchers bacon", "chunky bacon", "double cut bacon", "premium bacon", "thick bacon"]
2178	thimbleberries	["mountain berry", "rubus parviflorus", "thimbleberry", "western thimbleberry", "white flowering raspberry"]
2179	thousand island dressing	["1000 island", "big mac sauce style", "pink dressing", "russian dressing alternative", "sweet mayo dressing"]
2180	thyme oil	["cooking thyme oil", "french thyme oil", "garden thyme oil", "herbal thyme", "thymus oil"]
2181	tiger nuts	["chufa nuts", "earth almonds", "ground almonds alternative", "yellow nutsedge", "zulu nuts"]
2182	tilapia	["freshwater tilapia", "mild white fish", "nile tilapia", "st peter fish", "tilapia fillet"]
2183	tilsit	["german cheese tilsit", "prussian cheese", "semi hard tilsit", "swiss tilsit", "tilsiter"]
2184	toasted coconut	["browned coconut", "crispy coconut", "golden coconut", "roasted coconut", "toasted coconut flakes"]
2185	toasted sesame seeds	["asian sesame toasted", "cooked sesame", "golden sesame seeds", "roasted sesame", "tan sesame"]
2186	toffee bits	["baking toffee", "caramelized sugar bits", "english toffee bits", "heath bits", "toffee pieces"]
108	tofu	["bean curd", "doufu", "firm tofu", "regular tofu", "silken tofu", "soy tofu", "soya curd", "soybean curd"]
2188	tom yum paste	["hot and sour paste", "lemongrass paste", "spicy thai paste", "thai soup paste", "tom yam paste"]
2189	toma	["alpine toma", "italian toma", "toma cheese", "tome", "tomme"]
2190	tomatillos	["green tomatoes tomatillo", "husk tomatoes", "jamberberry", "mexican husk tomato", "tomatillo verde"]
109	tomato paste	["concentrated tomato paste", "double concentrated tomato", "tomato concentrate", "tomato puree concentrated", "tomato purée", "triple concentrated tomato", "tube tomato paste"]
2192	tomato puree	["pureed tomatoes", "smooth tomato", "strained tomatoes", "tomato passata", "tomato sauce smooth"]
110	tomato sauce	["crushed tomatoes thin", "marinara base", "marinara sauce", "pizza sauce base", "plain tomato sauce", "red sauce", "tomato passata", "tomato puree"]
2194	tomato seed oil	["lycopene oil", "lycopersicon oil", "red seed oil", "solanum oil", "tomato kernel oil"]
2195	tommy atkins mangoes	["common mangoes", "florida mangoes", "grocery mangoes", "red mangoes", "tommy atkins"]
2196	tongues of fire beans	["borlotti streaked", "horticultural beans", "italian cranberry", "lingua di fuoco", "wren egg beans"]
2197	tonkatsu sauce	["bull dog sauce", "japanese barbecue sauce", "katsu sauce", "pork cutlet sauce", "thick asian sauce"]
2198	toor dal	["arhar dal split", "pigeon pea dal", "split pigeon peas", "tur dal split", "yellow pigeon peas"]
2199	tortellini	["belly button pasta", "cheese tortellini", "filled tortellini", "meat tortellini", "stuffed rings"]
2200	tortelloni	["big belly buttons", "giant tortellini", "large tortellini", "oversized tortellini", "stuffed pasta large"]
2201	tortilla chips	["corn chips", "mexican chips", "nacho chips", "restaurant style chips", "yellow corn chips"]
112	tortillas	["burrito tortillas", "corn tortillas", "flour tortillas", "soft tortillas", "taco tortillas", "wraps"]
2203	tosaka	["coral seaweed", "japanese tosaka", "meristotheca", "red seaweed salad", "sea fern"]
2204	trail mix	["backpacker mix", "energy mix", "gorp", "hiking mix", "mixed nuts dried fruit"]
2205	treacle	["black treacle", "british molasses", "cooking treacle", "dark treacle", "refinery syrup dark"]
2206	tri-color quinoa	["assorted quinoa", "mixed quinoa", "multicolor quinoa", "quinoa blend", "rainbow quinoa"]
2207	tripe	["beef stomach", "blanket tripe", "honeycomb tripe", "menudo meat", "pho tripe"]
2208	triple cream brie	["75% brie", "brillat savarin", "delice de bourgogne", "explorateur", "rich brie"]
2209	triscuits	["fiber crackers", "shredded wheat crackers", "square wheat crackers", "whole grain triscuits", "woven wheat crackers"]
2210	triticale	["hybrid cereal", "modern grain", "triticale grain", "wheat rye cross", "wheat rye hybrid"]
2211	triticale flour	["ancient hybrid flour", "hybrid flour", "modern wheat flour", "triticale meal", "wheat rye flour"]
113	truffle oil	["black truffle oil", "synthetic truffle oil", "truffle infused oil", "truffle olive oil", "truffle-infused oil", "white truffle oil"]
2213	tuna canned	["albacore tuna canned", "canned tuna in oil", "canned tuna in water", "chunk light tuna", "solid white tuna"]
2214	tuna steak	["ahi tuna", "fresh tuna", "sushi grade tuna", "tuna fillet", "tuna loin"]
2215	turbinado sugar	["large crystal sugar", "partially refined sugar", "raw turbinado", "sugar in the raw", "washed raw sugar"]
2216	turbot	["brill", "european turbot", "flatfish turbot", "steinbutt", "turbot fillet"]
2217	turkey breast	["boneless turkey breast", "sliced turkey breast", "turkey breast cutlets", "turkey breast meat", "white meat turkey"]
2218	turkey drumsticks	["drumstick turkey", "giant drumsticks", "smoked turkey legs", "turkey leg meat", "turkey legs"]
2219	turkey thighs	["bone-in turkey thigh", "dark meat turkey", "thigh portions turkey", "turkey leg meat", "turkey thigh meat"]
2220	turkey wings	["braising wings", "smoked turkey wings", "turkey wing", "whole turkey wings", "wing portions turkey"]
2221	turmeric oil	["curcuma oil", "golden oil turmeric", "haldi oil", "indian turmeric", "yellow ginger oil"]
2222	turmeric powder	["curcuma", "ground turmeric", "haldi", "indian saffron", "yellow ginger powder"]
2223	turmeric root	["fresh turmeric", "raw turmeric", "turmeric", "turmeric rhizome", "yellow ginger"]
2224	turnip greens	["broccoli raab", "rapini", "turnip leaf", "turnip leaves", "turnip tops"]
2225	turnips	["garden turnips", "purple top turnips", "table turnips", "turnip", "white turnips"]
2226	turtle meat	["sea turtle alternative", "snapping turtle", "softshell turtle", "terrapin", "tortoise meat"]
2227	tvorog	["eastern curd cheese", "fresh cheese russian", "quark russian", "russian cottage cheese", "twarog"]
2228	udon noodles	["fresh udon", "japanese wheat noodles", "sanuki udon", "thick japanese noodles", "wheat udon"]
2229	ulluco	["andean tuber", "melloco", "olluco", "papa lisa", "ruba"]
2230	umeboshi vinegar	["japanese plum vinegar", "pickled plum vinegar", "plum vinegar", "red plum vinegar", "ume vinegar"]
2231	unflavored gelatin packets	["gelatin sachets", "individual gelatin", "knox gelatin packets", "powdered gelatin envelopes", "single serve gelatin"]
2232	unripe jackfruit	["canned young jackfruit", "pulled jackfruit", "savory jackfruit", "vegetarian meat alternative", "young green jackfruit"]
2233	unsalted butter	["fresh butter", "sweet butter", "sweet cream butter unsalted", "unsalted churned butter", "unsalted sweet cream butter"]
2234	unsweetened chocolate	["100% cacao", "bakers unsweetened", "bitter baking chocolate", "chocolate liquor solid", "pure chocolate"]
2235	unsweetened shredded coconut	["natural coconut shredded", "no sugar coconut", "plain coconut", "unsweetened coconut", "unsweetened flakes"]
2236	urad dal	["black gram dal", "hulled black gram", "split black lentils", "washed urad", "white urad dal"]
2237	urfa pepper	["burgundy pepper flakes", "isot pepper", "smoked turkish pepper", "sun dried pepper", "urfa biber"]
2238	vada mix	["doughnut mix", "instant vada", "lentil fritter mix", "medu vada mix", "urad dal mix"]
2239	valencia oranges	["juice oranges", "spanish oranges", "summer oranges", "sweet valencia", "valencia"]
2240	valentina hot sauce	["black label valentina", "mexican valentina", "orange valentina", "salsa valentina", "taco sauce mexican"]
2241	vanilla bean paste	["concentrated vanilla", "vanilla bean spread", "vanilla caviar", "vanilla extract thick", "vanilla paste"]
2242	vanilla beans	["bourbon beans", "madagascar vanilla", "tahitian vanilla", "vanilla pods", "whole vanilla"]
2243	vanilla extract	["bourbon vanilla", "mexican vanilla", "pure vanilla extract", "real vanilla", "vanilla flavoring"]
2244	vanilla infused oil	["dessert oil", "extract oil vanilla", "madagascar vanilla oil", "sweet vanilla oil", "vanilla bean oil"]
2245	veal chops	["bone-in veal", "veal chop", "veal cutlet thick", "veal loin chops", "veal rib chops"]
2246	veal cutlets	["breading veal", "thinly sliced veal", "veal escalope", "veal scallopini", "veal schnitzel"]
2247	veal shank	["braising veal", "cross cut veal", "marrow veal", "osso buco veal", "veal shin"]
2248	veal stock	["brown veal stock", "classic french stock", "fond de veau", "veal bone stock", "white veal stock"]
2249	vegan butter	["dairy free butter", "earth balance style", "non dairy butter", "plant based butter", "vegetable butter"]
2250	vegan mayonnaise	["dairy free mayo", "egg free mayo", "follow your heart mayo", "plant based mayo", "veganaise"]
2251	vegetable bouillon	["instant vegetable stock", "vegetable base powder", "vegetable concentrate", "vegetable stock powder", "veggie broth powder"]
2252	vegetable broth	["low sodium vegetable broth", "plant broth", "vegetable bouillon liquid", "vegetable stock", "veggie broth"]
2253	vegetable medley	["california blend", "mixed vegetables frozen", "normandy blend", "stir fry mix frozen", "vegetable blend"]
116	vegetable oil	["all purpose oil", "blended oil", "canola oil", "cooking oil", "corn oil", "neutral oil", "rapeseed oil", "salad oil"]
2255	vegetable stock concentrate	["concentrated vegetable stock", "vegan stock paste", "vegetable base", "vegetable bouillon paste", "veggie paste"]
2256	velvet beans	["bengal velvet bean", "buffalo beans", "cowhage", "monkey tamarind", "mucuna beans"]
2257	venison	["deer meat", "game meat venison", "red deer", "venison steak", "wild venison"]
2258	vietnamese coriander	["cambodian mint", "hot mint", "laksa leaf", "rau ram", "vietnamese cilantro"]
2259	viili	["finnish cultured milk", "ropy finnish milk", "scandinavian fermented milk", "string milk", "vili"]
118	vinegar	["apple cider vinegar", "cleaning vinegar", "distilled vinegar", "distilled white vinegar", "grain vinegar", "pickling vinegar", "white vinegar"]
2261	violet flowers	["edible violets", "purple violets", "sweet violets", "viola flowers", "wild violets"]
2262	virgin coconut oil	["cold pressed coconut", "extra virgin coconut", "organic coconut oil", "raw coconut oil", "unrefined coconut oil"]
2263	vital wheat gluten	["bread improver", "gluten powder", "pure gluten", "seitan flour", "wheat gluten flour"]
2264	vodka sauce	["creamy tomato vodka", "italian vodka sauce", "penne alla vodka sauce", "pink sauce", "tomato cream sauce"]
2265	wafer cookies	["banana pudding wafers", "nilla wafers", "thin cookies", "vanilla wafers", "wafer biscuits"]
2266	waffle mix	["belgian waffle mix", "buttermilk waffle mix", "complete waffle mix", "instant waffle mix", "waffle batter mix"]
2267	wakame	["japanese seaweed", "miyeok", "sea mustard", "undaria", "wakame strips"]
2268	walleye	["freshwater walleye", "great lakes fish", "pickerel", "walleye fillet", "yellow pike"]
2269	walnut butter	["creamy walnut butter", "natural walnut butter", "omega walnut butter", "walnut paste", "walnut spread"]
2270	walnut milk	["dairy free walnut", "nut milk walnut", "omega milk", "plant walnut milk", "walnut beverage"]
2271	walnut oil	["french walnut oil", "gourmet walnut oil", "nut oil walnut", "refined walnut oil", "toasted walnut oil"]
2272	walnut pieces	["baking walnuts", "broken walnuts", "chopped walnuts", "walnut bits", "walnut chips"]
119	walnuts	["california walnuts", "chopped walnuts", "english walnuts", "raw walnuts", "shelled walnuts", "walnut halves", "walnut pieces"]
2274	wasabi mayo	["green mayo", "japanese horseradish mayo", "spicy wasabi mayo", "sushi mayo", "wasabi aioli"]
2275	wasabi oil	["asian hot oil", "green wasabi oil", "japanese horseradish oil", "spicy wasabi", "sushi oil"]
2276	wasabi root	["fresh wasabi", "hon wasabi", "japanese horseradish root", "mountain hollyhock", "real wasabi"]
2277	water chestnuts	["caltrop", "chinese water chestnut", "fresh water chestnuts", "horn chestnut", "water chestnut"]
2278	water crackers	["bland crackers", "carr crackers", "neutral crackers", "plain crackers", "table water crackers"]
47	greek yogurt	["greek-style yogurt", "authentic greek yogurt", "greek style yogurt", "mediterranean yogurt", "strained yogurt", "thick yogurt", "yoghurt"]
2280	watermelon	["fresh watermelon", "red watermelon", "seeded watermelon", "summer melon", "watermelons"]
2281	watermelon radish	["beauty heart radish", "chinese radish watermelon", "red meat radish", "rose heart radish", "shinrimei radish"]
2282	watermelon seed oil	["african watermelon oil", "citrullus oil", "kalahari oil", "melon seed oil", "ootanga oil"]
2283	watermelon seeds	["asian watermelon seeds", "gua zi", "melon seeds", "pepitas alternative", "roasted watermelon seeds"]
2284	wax peppers	["banana type peppers", "hot wax peppers", "hungarian hot wax", "sweet hot peppers", "yellow hot peppers"]
2285	wheat berries	["hard wheat berries", "hulled wheat", "soft wheat berries", "wheat grain", "whole wheat kernels"]
2286	wheat bran	["bran fiber", "miller bran", "outer wheat", "wheat fiber", "wheat hull"]
2287	wheat germ	["raw wheat germ", "toasted wheat germ", "wheat embryo", "wheat heart", "wheat kernel"]
2288	wheat germ oil	["cereal oil", "cold pressed wheat germ", "triticum oil", "vitamin e oil", "whole wheat oil"]
2289	wheat thins	["nabisco wheat", "thin wheat crackers", "toasted wheat", "whole grain crackers", "whole wheat crackers"]
2290	wheatgrass	["green wheat", "sprouted wheat", "triticum grass", "wheat grass", "wheat shoots"]
2291	whelk	["buccinum", "buckie", "channeled whelk", "knobbed whelk", "sea snail whelk"]
2292	whey protein	["milk whey", "protein supplement", "whey concentrate", "whey isolate", "whey powder"]
2293	whipped butter	["aerated butter", "fluffy butter", "light butter whipped", "soft butter", "spreadable butter"]
2295	white asparagus	["albino asparagus", "blanched asparagus", "forced asparagus", "ivory asparagus", "white spears"]
121	white beans	["all white beans", "cannellini alternative", "cannellini beans", "generic white beans", "great northern alternative", "great northern beans", "navy alternative", "navy beans", "white kidney beans"]
2297	white bread	["enriched white bread", "sandwich white bread", "sliced white", "soft white bread", "wonder bread style"]
2298	white cheddar	["natural cheddar", "pale cheddar", "uncolored cheddar", "vermont white cheddar", "white sharp cheddar"]
2299	white chocolate	["cocoa butter chocolate", "ivory chocolate", "vanilla chocolate", "white baking chocolate", "white couverture"]
2300	white chocolate chips	["ivory chips", "vanilla chips", "white baking chips", "white chocolate pieces", "white morsels"]
2301	white currants	["champagne currants", "pale currants", "ribes blanc", "white currant", "whitecurrants"]
2302	white dragon fruit	["sweet pitaya", "thai dragon", "vietnam dragon", "white flesh dragon", "white pitaya"]
2303	white eggplant	["albino eggplant", "egg-shaped eggplant", "ivory eggplant", "white aubergine", "white brinjal"]
2304	white grapefruit	["duncan grapefruit", "marsh grapefruit", "pale grapefruit", "white flesh grapefruit", "yellow grapefruit"]
2305	white guava	["apple guava white", "crystal guava", "pearl guava", "thai guava", "white flesh guava"]
2306	white miso	["light miso", "mellow miso", "mild miso", "shiro miso", "sweet miso"]
2307	white nectarines	["arctic supreme", "pale nectarines", "sweet white nectarines", "white flesh nectarines", "white nectarine"]
2308	white onions	["mexican white onions", "mild onions", "sweet white onions", "white cooking onions", "white onion"]
2309	white peaches	["asian peaches", "donut peaches white", "pale peaches", "white flesh peaches", "white peach"]
2310	white pepper	["european pepper", "ground white pepper", "mild pepper", "pale pepper", "white peppercorns ground"]
2311	white peppercorns	["decorticated pepper", "muntok pepper", "sarawak pepper", "white pepper berries", "whole white pepper"]
2312	white rice	["long grain white rice", "plain white rice", "polished rice", "regular rice", "table rice"]
2313	white whole wheat flour	["albino wheat flour", "blonde whole wheat", "ivory wheat flour", "light whole wheat", "whole white wheat"]
2314	white wine vinegar	["champagne vinegar", "french white vinegar", "light vinegar", "mild wine vinegar", "white vinegar wine"]
2315	whole chicken	["chicken carcass", "entire chicken", "fresh whole chicken", "roasting chicken", "whole fryer"]
2316	whole duck	["dressed duck", "duck carcass", "fresh duck", "pekin duck", "roasting duck"]
2317	whole freekeh	["farik whole", "green wheat whole", "intact freekeh", "uncracked freekeh", "whole grain freekeh"]
2318	whole grain mustard	["coarse mustard", "country mustard", "grainy mustard", "pommery mustard", "seeded mustard"]
2319	whole milk	["3.25% milk", "full cream milk", "homogenized milk", "regular milk", "vitamin d milk"]
2320	whole milk yogurt	["4% yogurt", "creamy yogurt", "full fat yogurt", "plain whole yogurt", "regular fat yogurt"]
2321	whole nutmeg	["fresh nutmeg", "nutmeg berries", "nutmeg nuts", "nutmeg seed", "whole spice nutmeg"]
2322	whole peeled tomatoes	["canned whole tomatoes", "italian whole tomatoes", "peeled plum tomatoes", "san marzano", "whole italian tomatoes"]
2323	whole turkey	["fresh turkey", "holiday turkey", "roasting turkey", "thanksgiving turkey", "tom turkey"]
2324	whole wheat bread	["100% wheat bread", "brown bread", "healthy bread", "whole grain bread", "wholemeal bread"]
2325	whole wheat flour	["brown flour", "graham flour", "wheat flour whole", "whole grain flour", "wholemeal flour"]
2326	wild boar	["boar meat", "feral pig", "game boar", "tusker meat", "wild pork"]
2327	wild rice	["black wild rice", "canada rice", "indian rice grass", "water oats", "wild grain"]
2328	wildflower honey	["country honey", "meadow honey", "mixed blossom honey", "multi-floral honey", "polyfloral honey"]
2329	wineberries	["asian raspberry", "hairy raspberry", "japanese wineberry", "rubus phoenicolasius", "wine raspberry"]
2330	winged beans	["asparagus pea", "dragon beans", "four angled bean", "goa beans", "princess beans"]
2331	winged gourd	["angled gourd", "asparagus pea pod", "four angled bean", "goa bean pod", "princess bean pod"]
2332	winkles	["common winkle", "edible winkle", "periwinkle small", "sea snail small", "shore winkle"]
2333	wonton wrappers	["asian wrappers", "chinese wonton wrappers", "dumpling wrappers thin", "egg roll wrappers small", "wonton skins"]
2334	wood ear mushrooms	["black fungus", "cloud ear", "judas ear", "tree ear", "wood ear fungus"]
2335	woodcock	["american woodcock", "bog sucker", "game bird woodcock", "scolopax", "timberdoodle"]
2336	worcestershire sauce	["british brown sauce", "fermented sauce", "lea and perrins", "umami worcestershire", "worcester sauce"]
2337	xanthan gum	["gluten free binder", "stabilizer xanthan", "thickening agent xanthan", "xantham gum", "xanthan powder"]
2338	xo sauce	["chinese xo sauce", "dried seafood sauce", "hong kong xo", "luxury asian sauce", "spicy seafood condiment"]
2339	yak milk	["dri milk", "himalayan yak milk", "mongolian milk", "mountain milk", "tibetan milk"]
2340	yard long beans	["asparagus beans", "chinese long beans", "dow gauk", "long beans", "snake beans"]
125	yeast	["active dry yeast", "baker's yeast", "bakers yeast", "bread yeast", "fresh yeast", "instant yeast"]
2342	yeast extract	["autolyzed yeast", "marmite style", "nutritional yeast", "vegemite style", "yeast spread"]
2343	yellow bell peppers	["bell peppers yellow", "yellow bell pepper", "yellow capsicum", "yellow peppers", "yellow sweet peppers"]
2344	yellow curry paste	["gaeng garee", "indian style curry paste", "mild curry paste", "thai yellow curry", "turmeric curry paste"]
2345	yellow dragon fruit	["ecuadorian pitaya", "golden pitaya", "selenicereus", "sweet yellow dragon", "yellow pitaya"]
2346	yellow eye beans	["boston beans", "dried yellow eye", "maine yellow eye", "molasses face beans", "sulphur beans"]
2347	yellow lentils	["golden lentils", "hulled moong", "moong dal yellow", "split yellow", "yellow split lentils"]
2348	yellow miso	["all purpose miso", "golden miso", "medium miso", "shinshu miso", "versatile miso"]
2349	yellow mustard seeds	["american mustard seeds", "brassica alba", "mild mustard seeds", "prepared mustard base", "white mustard seeds"]
2350	yellow nectarines	["classic nectarines", "freestone nectarines", "golden nectarines", "summer nectarines", "yellow flesh nectarines"]
2351	yellow onions	["brown onions", "cooking onions", "spanish onions", "storage onions", "yellow onion"]
2352	yellow peaches	["classic peaches", "clingstone peaches", "freestone peaches", "golden peaches", "yellow flesh peaches"]
2353	yellow pear tomatoes	["pear shaped yellow", "small yellow pear", "sweet yellow pear", "tear drop yellow", "tiny yellow tomatoes"]
2354	yellow plums	["golden plums", "lemon plums", "mirabelle plums", "pale plums", "yellow skin plums"]
2355	yellow split peas	["chana dal alternative", "dried yellow peas", "golden split peas", "split yellow", "yellow split"]
2356	yellow squash	["crookneck squash", "golden zucchini", "straightneck squash", "summer squash yellow", "yellow zucchini"]
2357	yellow watermelon	["desert gold", "golden watermelon", "honey watermelon", "yellow flesh watermelon", "yellow heart"]
2358	yellow wax beans	["butter beans yellow", "golden wax beans", "wax beans", "yellow beans", "yellow string beans"]
2359	yellowfin tuna	["ahi", "albacore alternative", "sushi tuna", "yellow fin", "yellowfin ahi"]
2360	yogurt starter	["bulgarian starter", "live culture starter", "probiotic starter", "thermophilic culture", "yogurt culture"]
2361	young coconuts	["drinking coconut", "green coconut", "thai coconut", "white coconut", "young coconut"]
2362	yu choy	["chinese flowering cabbage", "choy sum", "flowering cabbage", "oil vegetable", "yu choi"]
2363	yuba	["bean curd skin", "dried tofu skin", "foo jook", "soy milk skin", "tofu skin"]
2364	yuca flour	["brazilian flour", "cassava flour", "manioc flour", "tapioca flour alternative", "yucca flour"]
2365	yuca root	["brazilian arrowroot", "cassava", "manioc", "tapioca root", "yucca root"]
2366	yukon gold potatoes	["buttery potatoes", "golden potatoes", "yellow potatoes", "yellow-fleshed potatoes", "yukon gold"]
2367	yuzu	["asian lemon", "citrus yuzu", "japanese citron", "yuja", "yuzu fruit"]
2368	yuzu kosho	["fermented yuzu", "green yuzu kosho", "japanese citrus paste", "spicy yuzu", "yuzu pepper paste"]
2369	za atar	["levantine za atar", "middle eastern spice mix", "thyme blend", "zaatar", "zatar blend"]
2370	zahidi dates	["bread dates", "butter dates", "dough dates", "golden dates", "semi dry zahidi"]
2371	zedoary	["amba haldi", "kachur", "shoti", "white turmeric", "zedoary root"]
2372	ziti	["baked ziti pasta", "bridegroom pasta", "bucatini alternative", "long macaroni", "smooth tubes"]
2374	zucchini noodles	["courgette noodles", "spiralized zucchini", "vegetable pasta", "veggie noodles", "zoodles"]
48	green curry paste	["thai green curry paste", "gaeng keow wan", "green chili curry paste", "green chili paste", "herbal curry paste", "mild green curry", "thai green curry"]
53	hot sauce	["tabasco", "cayenne sauce", "chili sauce", "louisiana hot sauce", "pepper sauce", "red hot sauce", "sriracha"]
54	kalamata olives	["greek olives", "kalamata olives", "almond shaped olives", "black olives", "greek black olives", "kalamata greek", "purple olives", "wine cured olives"]
2373	zucchini	["zucchini", "courgette", "courgettes", "baby marrow", "summer squash", "green squash", "italian squash", "green zucchini"]
1363	lamb shank	["braised lamb shank", "foreshaank lamb", "hindshank lamb", "lamb shin", "osso buco lamb"]
72	olive oil	["evoo", "cooking olive oil", "extra virgin olive oil", "light olive oil", "pure olive oil", "refined olive oil", "standard olive oil", "virgin olive oil"]
79	parmesan cheese	["parm", "parmesan", "parmigiano-reggiano", "domestic parmesan", "grated parmesan cheese", "grated parmesan", "hard italian cheese", "parm", "shredded parmesan"]
87	pita bread	["arabic bread", "syrian bread", "greek pita", "mediterranean flatbread", "pita", "pita pockets", "pocket bread"]
88	pork shoulder	["boston butt", "boston butt", "picnic shoulder", "pork butt", "pork shoulder roast", "pulled pork meat", "shoulder roast"]
107	thai basil	["asian basil", "ocimum basilicum var. thyrsiflora", "thai sweet basil", "asian basil", "holy basil", "horapha", "licorice basil", "oriental sweet basil"]
2294	whipping cream	["30% cream", "light whipping cream", "pouring cream thick", "single cream thick", "whipping cream light"]
\.


--
-- Data for Name: recipe_ingredients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recipe_ingredients (id, recipe_id, ingredient_id, ingredient_name, recipe_name) FROM stdin;
1	181	56	lemon	Chicken Caesar Salad
2	137	111	tomatoes	Beef Lasagna
3	136	97	salt	Simple Pasta
6	173	61	lime	Fish Tacos
156	126	42	flour	Scrambled Eggs
157	152	24	chicken breast	Thai Green Curry
158	143	5	balsamic vinegar	Caprese Salad
311	229	62	milk	French Toast
312	113	12	bread	Buttered Toast
313	179	123	white wine	Mushroom Risotto
465	184	16	butter	Grilled Cheese
466	206	28	cinnamon	French Toast
467	227	97	salt	Simple Pasta
619	169	93	rice	Chicken and Rice
620	13	63	mint	Keftedes
621	131	45	ginger	Grilled Cheese
623	213	43	garlic	Beef Lasagna
774	223	111	tomatoes	Scrambled Eggs
775	6	62	milk	Pastitsio
776	110	97	salt	Chicken Alfredo
777	217	22	cheese	Mushroom Risotto
778	25	14	broccoli	Chicken Stir Fry
928	142	24	chicken breast	Chicken Caesar Salad
929	211	97	salt	Cheese Omelette
930	126	111	tomatoes	Scrambled Eggs
931	51	104	sugar	Pancakes
4	29	3	baking powder	Pancakes
5	28	50	ground beef	Beef Tacos
7	120	62	milk	Loaded Baked Potato
8	106	22	cheese	Beef Tacos
9	1	97	salt	Moussaka
10	100	43	garlic	Bob's Demo Pasta
11	145	42	flour	Egg Fried Rice
12	119	97	salt	Caprese Salad
13	168	111	tomatoes	Caprese Salad
14	194	72	olive oil	Chicken Parmesan
15	186	72	olive oil	Garlic Bread
16	181	24	chicken breast	Chicken Caesar Salad
17	149	62	milk	Spinach Quiche
18	178	39	eggs	French Toast
19	124	62	milk	Mashed Potatoes
20	2	83	pepper	Souvlaki
21	10	21	celery	Avgolemono Soup
22	127	39	eggs	Spinach Quiche
23	200	97	salt	Spinach Quiche
24	116	97	salt	Carbonara Pasta
26	158	97	salt	Chicken Parmesan
27	84	109	tomato paste	Stifado
28	129	89	potatoes	Mashed Potatoes
29	209	72	olive oil	Chicken and Rice
30	145	22	cheese	Egg Fried Rice
31	194	7	basil	Chicken Parmesan
32	3	111	tomatoes	Greek Salad (Horiatiki)
33	191	100	shrimp	Seafood Paella
34	112	80	parsley	Seafood Paella
35	157	20	carrots	Vegetable Stir Fry
36	188	97	salt	Carbonara Pasta
37	146	97	salt	Chicken Alfredo
38	92	57	lemon juice	Psarosoupa
39	133	72	olive oil	Egg Fried Rice
40	15	80	parsley	Melitzanosalata
41	156	56	lemon	Chicken Caesar Salad
42	193	34	croutons	Chicken Caesar Salad
43	6	110	tomato sauce	Pastitsio
44	182	97	salt	Beef Lasagna
45	89	83	pepper	Moussaka
46	214	72	olive oil	Egg Fried Rice
47	89	74	onion	Moussaka
48	7	47	greek yogurt	Tzatziki
49	110	24	chicken breast	Chicken Alfredo
50	183	41	fish sauce	Thai Green Curry
51	4	16	butter	Spanakopita
52	202	81	pasta	Simple Pasta
53	220	97	salt	Mashed Potatoes
54	2	72	olive oil	Souvlaki
55	114	28	cinnamon	French Toast
56	136	81	pasta	Simple Pasta
57	154	62	milk	Tomato Soup
58	169	43	garlic	Chicken and Rice
59	116	81	pasta	Carbonara Pasta
60	7	57	lemon juice	Tzatziki
61	9	84	phyllo dough	Baklava
62	6	43	garlic	Pastitsio
63	7	72	olive oil	Tzatziki
64	178	115	vanilla	French Toast
65	8	72	olive oil	Fasolada
66	135	60	lettuce	Vegetable Stir Fry
67	105	56	lemon	Caesar Salad
68	158	39	eggs	Chicken Parmesan
69	51	39	eggs	Pancakes
70	1	39	eggs	Moussaka
71	125	62	milk	Tomato Soup
72	1	92	red wine	Moussaka
73	210	24	chicken breast	Chicken Alfredo
74	216	111	tomatoes	Tomato Soup
75	224	7	basil	Chicken Parmesan
76	165	72	olive oil	Beef Lasagna
77	192	97	salt	Beef Lasagna
78	122	97	salt	Chicken Parmesan
79	203	16	butter	Mashed Potatoes
80	29	115	vanilla	Pancakes
81	138	90	quinoa	Tomato Soup
82	31	101	sour cream	Beef Tacos
84	198	53	hot sauce	Fish Tacos
85	117	27	cilantro	Fish Tacos
86	103	111	tomatoes	Bob's Demo Pasta
87	166	83	pepper	Loaded Baked Potato
88	125	43	garlic	Tomato Soup
89	92	89	potatoes	Psarosoupa
91	90	88	pork shoulder	Souvlaki
92	188	81	pasta	Carbonara Pasta
93	198	61	lime	Fish Tacos
94	183	104	sugar	Thai Green Curry
95	123	83	pepper	Chicken and Rice
96	210	16	butter	Chicken Alfredo
97	217	66	mushrooms	Mushroom Risotto
98	29	42	flour	Pancakes
99	2	76	oregano	Souvlaki
100	168	7	basil	Caprese Salad
101	27	56	lemon	Caesar Salad
102	130	39	eggs	Chicken Parmesan
103	15	57	lemon juice	Melitzanosalata
104	229	39	eggs	French Toast
105	138	62	milk	Tomato Soup
106	124	16	butter	Mashed Potatoes
107	1	38	eggplant	Moussaka
108	3	49	green pepper	Greek Salad (Horiatiki)
1083	151	22	cheese	Carbonara Pasta
109	121	83	pepper	Scrambled Eggs
110	105	78	parmesan	Caesar Salad
111	210	83	pepper	Chicken Alfredo
112	201	97	salt	Loaded Baked Potato
113	201	89	potatoes	Loaded Baked Potato
114	122	7	basil	Chicken Parmesan
115	14	120	water	Galaktoboureko
116	84	30	cloves	Stifado
117	131	81	pasta	Grilled Cheese
118	25	93	rice	Chicken Stir Fry
119	216	43	garlic	Tomato Soup
120	183	107	thai basil	Thai Green Curry
121	51	3	baking powder	Pancakes
122	203	89	potatoes	Mashed Potatoes
123	228	111	tomatoes	Seafood Paella
124	90	43	garlic	Souvlaki
125	178	16	butter	French Toast
126	173	101	sour cream	Fish Tacos
127	134	22	cheese	Chicken Alfredo
128	28	105	taco shells	Beef Tacos
129	90	111	tomatoes	Souvlaki
130	140	50	ground beef	Cheese Omelette
131	206	62	milk	French Toast
132	167	97	salt	Scrambled Eggs
133	3	97	salt	Greek Salad (Horiatiki)
134	185	111	tomatoes	Fresh Salad
135	146	42	flour	Chicken Alfredo
136	112	93	rice	Seafood Paella
137	126	16	butter	Scrambled Eggs
138	200	39	eggs	Spinach Quiche
139	8	21	celery	Fasolada
140	171	16	butter	Mashed Potatoes
142	215	89	potatoes	Loaded Baked Potato
143	195	22	cheese	Grilled Cheese
144	154	43	garlic	Tomato Soup
145	186	12	bread	Garlic Bread
146	89	50	ground beef	Moussaka
147	204	72	olive oil	Egg Fried Rice
148	17	40	feta cheese	Kleftiko
149	3	76	oregano	Greek Salad (Horiatiki)
150	112	95	saffron	Seafood Paella
151	227	43	garlic	Simple Pasta
152	185	72	olive oil	Fresh Salad
153	178	104	sugar	French Toast
154	1	72	olive oil	Moussaka
159	139	93	rice	Chicken and Rice
160	17	55	lamb shoulder	Kleftiko
161	139	72	olive oil	Chicken and Rice
162	119	72	olive oil	Caprese Salad
163	176	62	milk	Mashed Potatoes
164	142	22	cheese	Chicken Caesar Salad
165	8	109	tomato paste	Fasolada
166	181	60	lettuce	Chicken Caesar Salad
167	5	37	dill	Dolmades
168	151	43	garlic	Carbonara Pasta
169	6	42	flour	Pastitsio
170	13	39	eggs	Keftedes
171	162	83	pepper	Spinach Quiche
172	210	42	flour	Chicken Alfredo
173	180	39	eggs	Spinach Quiche
174	184	22	cheese	Grilled Cheese
175	177	72	olive oil	Simple Pasta
176	24	12	bread	Grilled Cheese Sandwich
177	5	57	lemon juice	Dolmades
178	29	104	sugar	Pancakes
179	210	81	pasta	Chicken Alfredo
180	169	83	pepper	Chicken and Rice
181	156	18	caesar dressing	Chicken Caesar Salad
182	92	122	white fish	Psarosoupa
183	148	111	tomatoes	Fresh Salad
184	143	111	tomatoes	Caprese Salad
185	116	2	bacon	Carbonara Pasta
186	187	43	garlic	Tomato Soup
188	147	12	bread	Buttered Toast
189	224	39	eggs	Chicken Parmesan
190	156	22	cheese	Chicken Caesar Salad
191	227	72	olive oil	Simple Pasta
192	156	60	lettuce	Chicken Caesar Salad
193	211	16	butter	Cheese Omelette
194	204	93	rice	Egg Fried Rice
195	172	16	butter	Scrambled Eggs
196	5	80	parsley	Dolmades
198	2	57	lemon juice	Souvlaki
199	108	42	flour	Pancakes
200	142	60	lettuce	Chicken Caesar Salad
201	206	12	bread	French Toast
202	188	22	cheese	Carbonara Pasta
203	165	50	ground beef	Beef Lasagna
204	162	97	salt	Spinach Quiche
205	189	97	salt	Caprese Salad
206	119	65	mozzarella	Caprese Salad
207	153	27	cilantro	Fish Tacos
208	222	83	pepper	Spinach Quiche
209	227	81	pasta	Simple Pasta
210	158	24	chicken breast	Chicken Parmesan
211	141	43	garlic	Garlic Bread
212	90	97	salt	Souvlaki
213	179	66	mushrooms	Mushroom Risotto
214	199	43	garlic	Garlic Bread
215	173	112	tortillas	Fish Tacos
216	215	97	salt	Loaded Baked Potato
217	91	16	butter	Tiropita
218	103	72	olive oil	Bob's Demo Pasta
219	166	62	milk	Loaded Baked Potato
220	217	43	garlic	Mushroom Risotto
221	232	39	eggs	Carbonara Pasta
222	14	104	sugar	Galaktoboureko
223	135	42	flour	Vegetable Stir Fry
224	146	81	pasta	Chicken Alfredo
225	168	97	salt	Caprese Salad
226	127	22	cheese	Spinach Quiche
227	5	36	currants	Dolmades
228	165	111	tomatoes	Beef Lasagna
229	165	7	basil	Beef Lasagna
230	127	97	salt	Spinach Quiche
231	110	16	butter	Chicken Alfredo
232	161	22	cheese	Cheese Omelette
233	89	92	red wine	Moussaka
234	4	97	salt	Spanakopita
235	144	72	olive oil	Seafood Paella
237	153	17	cabbage	Fish Tacos
238	220	16	butter	Mashed Potatoes
239	225	56	lemon	Chicken Caesar Salad
240	229	28	cinnamon	French Toast
241	216	83	pepper	Tomato Soup
242	115	16	butter	Garlic Bread
243	10	93	rice	Avgolemono Soup
244	145	16	butter	Egg Fried Rice
245	149	103	spinach	Spinach Quiche
246	155	12	bread	Garlic Bread
247	224	111	tomatoes	Chicken Parmesan
248	120	22	cheese	Loaded Baked Potato
249	89	97	salt	Moussaka
250	178	62	milk	French Toast
251	190	83	pepper	Vegetable Stir Fry
252	140	60	lettuce	Cheese Omelette
253	192	76	oregano	Beef Lasagna
254	217	123	white wine	Mushroom Risotto
255	199	12	bread	Garlic Bread
256	198	27	cilantro	Fish Tacos
257	30	56	lemon	Caesar Salad
258	171	62	milk	Mashed Potatoes
259	132	72	olive oil	Fresh Salad
260	84	8	bay leaves	Stifado
261	160	81	pasta	Simple Pasta
262	105	18	caesar dressing	Caesar Salad
263	12	74	onion	Gigantes Plaki
264	130	7	basil	Chicken Parmesan
265	194	39	eggs	Chicken Parmesan
266	51	62	milk	Pancakes
267	15	72	olive oil	Melitzanosalata
268	118	104	sugar	Thai Green Curry
269	203	62	milk	Mashed Potatoes
270	4	94	ricotta cheese	Spanakopita
271	4	40	feta cheese	Spanakopita
272	215	2	bacon	Loaded Baked Potato
273	124	83	pepper	Mashed Potatoes
274	177	81	pasta	Simple Pasta
275	197	111	tomatoes	Tomato Soup
276	208	97	salt	Scrambled Eggs
277	179	16	butter	Mushroom Risotto
278	134	97	salt	Chicken Alfredo
279	223	11	bell peppers	Scrambled Eggs
280	130	22	cheese	Chicken Parmesan
281	180	62	milk	Spinach Quiche
282	16	120	water	Loukoumades
283	115	72	olive oil	Garlic Bread
284	221	72	olive oil	Caprese Salad
285	164	93	rice	Seafood Paella
286	206	16	butter	French Toast
287	191	43	garlic	Seafood Paella
288	176	89	potatoes	Mashed Potatoes
289	118	6	bamboo shoots	Thai Green Curry
290	91	94	ricotta cheese	Tiropita
291	110	42	flour	Chicken Alfredo
292	28	22	cheese	Beef Tacos
293	1	79	parmesan cheese	Moussaka
295	138	106	tahini	Tomato Soup
296	17	76	oregano	Kleftiko
297	170	81	pasta	Carbonara Pasta
298	111	85	pie crust	Spinach Quiche
299	201	83	pepper	Loaded Baked Potato
300	220	83	pepper	Mashed Potatoes
301	220	62	milk	Mashed Potatoes
302	178	28	cinnamon	French Toast
303	111	39	eggs	Spinach Quiche
304	193	22	cheese	Chicken Caesar Salad
305	1	74	onion	Moussaka
306	24	16	butter	Grilled Cheese Sandwich
308	144	56	lemon	Seafood Paella
309	212	16	butter	Chicken Parmesan
310	194	111	tomatoes	Chicken Parmesan
314	145	39	eggs	Egg Fried Rice
315	15	83	pepper	Melitzanosalata
316	197	43	garlic	Tomato Soup
317	1	68	nutmeg	Moussaka
318	140	42	flour	Cheese Omelette
319	13	77	ouzo	Keftedes
320	108	62	milk	Pancakes
321	161	97	salt	Cheese Omelette
322	110	22	cheese	Chicken Alfredo
323	16	71	oil for frying	Loukoumades
324	12	72	olive oil	Gigantes Plaki
326	196	72	olive oil	Caprese Salad
328	155	16	butter	Garlic Bread
329	154	83	pepper	Tomato Soup
330	14	58	lemon zest	Galaktoboureko
331	84	118	vinegar	Stifado
332	116	39	eggs	Carbonara Pasta
333	162	39	eggs	Spinach Quiche
334	232	2	bacon	Carbonara Pasta
335	222	97	salt	Spinach Quiche
336	17	72	olive oil	Kleftiko
337	215	101	sour cream	Loaded Baked Potato
338	122	42	flour	Chicken Parmesan
339	174	39	eggs	Cheese Omelette
340	51	16	butter	Pancakes
341	133	102	soy sauce	Egg Fried Rice
343	120	16	butter	Loaded Baked Potato
344	28	60	lettuce	Beef Tacos
345	176	97	salt	Mashed Potatoes
346	191	67	mussels	Seafood Paella
347	92	20	carrots	Psarosoupa
348	166	101	sour cream	Loaded Baked Potato
349	161	16	butter	Cheese Omelette
350	31	50	ground beef	Beef Tacos
351	89	72	olive oil	Moussaka
352	189	72	olive oil	Caprese Salad
353	153	122	white fish	Fish Tacos
354	117	112	tortillas	Fish Tacos
355	107	42	flour	Pancakes
356	205	83	pepper	Vegetable Stir Fry
357	129	97	salt	Mashed Potatoes
358	141	97	salt	Garlic Bread
359	168	5	balsamic vinegar	Caprese Salad
360	228	24	chicken breast	Seafood Paella
361	117	17	cabbage	Fish Tacos
362	144	80	parsley	Seafood Paella
363	31	105	taco shells	Beef Tacos
364	152	32	coconut milk	Thai Green Curry
365	116	72	olive oil	Carbonara Pasta
366	164	72	olive oil	Seafood Paella
367	231	12	bread	Buttered Toast
368	221	111	tomatoes	Caprese Salad
369	224	13	bread crumbs	Chicken Parmesan
370	165	81	pasta	Beef Lasagna
371	165	97	salt	Beef Lasagna
372	169	72	olive oil	Chicken and Rice
373	153	112	tortillas	Fish Tacos
374	192	7	basil	Beef Lasagna
375	14	99	semolina	Galaktoboureko
376	191	56	lemon	Seafood Paella
377	130	24	chicken breast	Chicken Parmesan
378	160	72	olive oil	Simple Pasta
379	182	22	cheese	Beef Lasagna
380	142	56	lemon	Chicken Caesar Salad
381	177	97	salt	Simple Pasta
382	214	102	soy sauce	Egg Fried Rice
383	170	43	garlic	Carbonara Pasta
384	194	43	garlic	Chicken Parmesan
385	196	97	salt	Caprese Salad
386	105	60	lettuce	Caesar Salad
387	118	32	coconut milk	Thai Green Curry
388	154	16	butter	Tomato Soup
389	3	72	olive oil	Greek Salad (Horiatiki)
390	13	43	garlic	Keftedes
391	176	83	pepper	Mashed Potatoes
392	230	24	chicken breast	Chicken and Rice
393	16	52	honey	Loukoumades
394	181	18	caesar dressing	Chicken Caesar Salad
395	205	20	carrots	Vegetable Stir Fry
396	143	7	basil	Caprese Salad
397	137	97	salt	Beef Lasagna
398	138	83	pepper	Tomato Soup
399	177	43	garlic	Simple Pasta
400	107	104	sugar	Pancakes
401	172	97	salt	Scrambled Eggs
402	110	62	milk	Chicken Alfredo
403	194	24	chicken breast	Chicken Parmesan
404	182	72	olive oil	Beef Lasagna
405	158	22	cheese	Chicken Parmesan
406	226	22	cheese	Grilled Cheese
407	194	42	flour	Chicken Parmesan
408	2	111	tomatoes	Souvlaki
409	206	39	eggs	French Toast
410	194	13	bread crumbs	Chicken Parmesan
411	12	37	dill	Gigantes Plaki
412	170	72	olive oil	Carbonara Pasta
413	103	43	garlic	Bob's Demo Pasta
414	127	62	milk	Spinach Quiche
415	224	22	cheese	Chicken Parmesan
416	148	60	lettuce	Fresh Salad
417	143	97	salt	Caprese Salad
418	200	62	milk	Spinach Quiche
419	92	74	onion	Psarosoupa
420	191	80	parsley	Seafood Paella
421	134	62	milk	Chicken Alfredo
422	26	43	garlic	Tomato Soup
423	143	65	mozzarella	Caprese Salad
424	139	24	chicken breast	Chicken and Rice
425	231	64	miso paste	Buttered Toast
426	186	16	butter	Garlic Bread
427	230	72	olive oil	Chicken and Rice
428	5	72	olive oil	Dolmades
429	174	62	milk	Cheese Omelette
430	84	92	red wine	Stifado
431	171	89	potatoes	Mashed Potatoes
432	89	109	tomato paste	Moussaka
433	223	89	potatoes	Scrambled Eggs
434	123	97	salt	Chicken and Rice
435	182	50	ground beef	Beef Lasagna
436	184	12	bread	Grilled Cheese
437	109	43	garlic	Mushroom Risotto
438	106	60	lettuce	Beef Tacos
439	204	39	eggs	Egg Fried Rice
440	192	22	cheese	Beef Lasagna
441	141	95	saffron	Garlic Bread
442	193	60	lettuce	Chicken Caesar Salad
443	190	11	bell peppers	Vegetable Stir Fry
444	15	38	eggplant	Melitzanosalata
445	163	93	rice	Egg Fried Rice
446	210	43	garlic	Chicken Alfredo
448	8	20	carrots	Fasolada
449	25	45	ginger	Chicken Stir Fry
450	1	50	ground beef	Moussaka
451	114	39	eggs	French Toast
452	191	72	olive oil	Seafood Paella
453	112	67	mussels	Seafood Paella
454	100	81	pasta	Bob's Demo Pasta
455	31	96	salsa	Beef Tacos
456	144	93	rice	Seafood Paella
457	164	11	bell peppers	Seafood Paella
458	172	39	eggs	Scrambled Eggs
459	182	111	tomatoes	Beef Lasagna
460	100	111	tomatoes	Bob's Demo Pasta
461	30	18	caesar dressing	Caesar Salad
462	174	83	pepper	Cheese Omelette
463	12	97	salt	Gigantes Plaki
464	219	83	pepper	Cheese Omelette
468	1	109	tomato paste	Moussaka
469	137	22	cheese	Beef Lasagna
470	16	125	yeast	Loukoumades
472	150	22	cheese	Mashed Potatoes
473	205	11	bell peppers	Vegetable Stir Fry
474	134	43	garlic	Chicken Alfredo
475	123	43	garlic	Chicken and Rice
476	183	32	coconut milk	Thai Green Curry
477	137	50	ground beef	Beef Lasagna
478	108	104	sugar	Pancakes
479	122	24	chicken breast	Chicken Parmesan
480	89	38	eggplant	Moussaka
481	200	85	pie crust	Spinach Quiche
482	185	60	lettuce	Fresh Salad
483	216	113	truffle oil	Tomato Soup
484	139	83	pepper	Chicken and Rice
485	139	97	salt	Chicken and Rice
486	29	62	milk	Pancakes
487	108	39	eggs	Pancakes
488	193	18	caesar dressing	Chicken Caesar Salad
489	162	103	spinach	Spinach Quiche
490	167	39	eggs	Scrambled Eggs
491	122	13	bread crumbs	Chicken Parmesan
492	89	16	butter	Moussaka
493	6	16	butter	Pastitsio
494	27	34	croutons	Caesar Salad
495	213	97	salt	Beef Lasagna
496	176	16	butter	Mashed Potatoes
497	124	89	potatoes	Mashed Potatoes
498	219	22	cheese	Cheese Omelette
499	8	74	onion	Fasolada
500	4	80	parsley	Spanakopita
501	5	74	onion	Dolmades
502	155	43	garlic	Garlic Bread
503	167	16	butter	Scrambled Eggs
504	192	72	olive oil	Beef Lasagna
505	134	24	chicken breast	Chicken Alfredo
506	108	16	butter	Pancakes
507	146	24	chicken breast	Chicken Alfredo
508	201	62	milk	Loaded Baked Potato
509	6	50	ground beef	Pastitsio
510	123	24	chicken breast	Chicken and Rice
511	197	62	milk	Tomato Soup
512	17	123	white wine	Kleftiko
513	231	95	saffron	Buttered Toast
514	2	87	pita bread	Souvlaki
516	223	20	carrots	Scrambled Eggs
517	3	54	kalamata olives	Greek Salad (Horiatiki)
518	25	43	garlic	Chicken Stir Fry
519	114	104	sugar	French Toast
520	201	101	sour cream	Loaded Baked Potato
521	14	115	vanilla	Galaktoboureko
522	225	113	truffle oil	Chicken Caesar Salad
523	230	43	garlic	Chicken and Rice
525	1	16	butter	Moussaka
526	90	76	oregano	Souvlaki
527	215	22	cheese	Loaded Baked Potato
528	29	16	butter	Pancakes
529	130	111	tomatoes	Chicken Parmesan
530	232	97	salt	Carbonara Pasta
531	9	104	sugar	Baklava
532	208	39	eggs	Scrambled Eggs
533	224	42	flour	Chicken Parmesan
534	213	12	bread	Beef Lasagna
535	196	111	tomatoes	Caprese Salad
536	149	97	salt	Spinach Quiche
537	13	51	ground pork	Keftedes
538	112	56	lemon	Seafood Paella
539	163	97	salt	Egg Fried Rice
540	30	60	lettuce	Caesar Salad
541	219	106	tahini	Cheese Omelette
542	190	72	olive oil	Vegetable Stir Fry
543	219	95	saffron	Cheese Omelette
544	138	16	butter	Tomato Soup
545	89	42	flour	Moussaka
546	90	87	pita bread	Souvlaki
547	13	42	flour	Keftedes
548	181	34	croutons	Chicken Caesar Salad
549	8	8	bay leaves	Fasolada
550	125	97	salt	Tomato Soup
551	25	102	soy sauce	Chicken Stir Fry
552	188	83	pepper	Carbonara Pasta
553	130	13	bread crumbs	Chicken Parmesan
554	200	22	cheese	Spinach Quiche
555	13	13	bread crumbs	Keftedes
556	125	111	tomatoes	Tomato Soup
557	217	16	butter	Mushroom Risotto
558	31	22	cheese	Beef Tacos
559	215	16	butter	Loaded Baked Potato
560	161	62	milk	Cheese Omelette
561	226	12	bread	Grilled Cheese
562	9	1	almonds	Baklava
563	89	39	eggs	Moussaka
564	1	43	garlic	Moussaka
565	155	72	olive oil	Garlic Bread
566	119	5	balsamic vinegar	Caprese Salad
567	192	50	ground beef	Beef Lasagna
568	84	82	pearl onions	Stifado
569	91	40	feta cheese	Tiropita
570	122	39	eggs	Chicken Parmesan
571	206	104	sugar	French Toast
572	112	11	bell peppers	Seafood Paella
573	193	56	lemon	Chicken Caesar Salad
574	129	113	truffle oil	Mashed Potatoes
575	13	74	onion	Keftedes
576	131	102	soy sauce	Grilled Cheese
577	198	17	cabbage	Fish Tacos
578	221	65	mozzarella	Caprese Salad
579	136	43	garlic	Simple Pasta
580	125	16	butter	Tomato Soup
581	5	86	pine nuts	Dolmades
582	135	16	butter	Vegetable Stir Fry
583	91	68	nutmeg	Tiropita
584	146	62	milk	Chicken Alfredo
585	222	64	miso paste	Spinach Quiche
586	122	22	cheese	Chicken Parmesan
587	119	7	basil	Caprese Salad
588	224	72	olive oil	Chicken Parmesan
590	161	39	eggs	Cheese Omelette
591	164	67	mussels	Seafood Paella
592	189	65	mozzarella	Caprese Salad
593	134	81	pasta	Chicken Alfredo
594	165	43	garlic	Beef Lasagna
595	192	111	tomatoes	Beef Lasagna
596	180	103	spinach	Spinach Quiche
597	192	81	pasta	Beef Lasagna
598	182	43	garlic	Beef Lasagna
599	89	68	nutmeg	Moussaka
600	194	97	salt	Chicken Parmesan
601	5	97	salt	Dolmades
602	180	85	pie crust	Spinach Quiche
603	115	12	bread	Garlic Bread
604	128	16	butter	Buttered Toast
605	215	62	milk	Loaded Baked Potato
606	8	97	salt	Fasolada
607	91	84	phyllo dough	Tiropita
608	132	60	lettuce	Fresh Salad
609	17	56	lemon	Kleftiko
610	112	100	shrimp	Seafood Paella
611	89	62	milk	Moussaka
612	51	42	flour	Pancakes
613	202	72	olive oil	Simple Pasta
614	13	50	ground beef	Keftedes
615	152	104	sugar	Thai Green Curry
616	7	37	dill	Tzatziki
617	6	28	cinnamon	Pastitsio
618	164	100	shrimp	Seafood Paella
622	156	24	chicken breast	Chicken Caesar Salad
625	230	83	pepper	Chicken and Rice
626	191	93	rice	Seafood Paella
627	205	43	garlic	Vegetable Stir Fry
628	218	42	flour	Thai Green Curry
629	141	90	quinoa	Garlic Bread
630	229	115	vanilla	French Toast
631	203	97	salt	Mashed Potatoes
632	164	95	saffron	Seafood Paella
633	117	122	white fish	Fish Tacos
634	173	122	white fish	Fish Tacos
635	112	43	garlic	Seafood Paella
636	222	62	milk	Spinach Quiche
637	201	16	butter	Loaded Baked Potato
638	154	97	salt	Tomato Soup
639	162	22	cheese	Spinach Quiche
640	191	95	saffron	Seafood Paella
641	122	111	tomatoes	Chicken Parmesan
642	159	16	butter	Buttered Toast
643	109	72	olive oil	Mushroom Risotto
645	186	43	garlic	Garlic Bread
646	169	97	salt	Chicken and Rice
647	182	81	pasta	Beef Lasagna
648	179	43	garlic	Mushroom Risotto
649	25	23	chicken	Chicken Stir Fry
650	138	43	garlic	Tomato Soup
651	222	22	cheese	Spinach Quiche
652	155	97	salt	Garlic Bread
653	232	22	cheese	Carbonara Pasta
654	7	43	garlic	Tzatziki
655	116	83	pepper	Carbonara Pasta
656	109	93	rice	Mushroom Risotto
657	130	97	salt	Chicken Parmesan
658	216	16	butter	Tomato Soup
659	5	63	mint	Dolmades
660	51	115	vanilla	Pancakes
661	171	97	salt	Mashed Potatoes
662	3	35	cucumber	Greek Salad (Horiatiki)
663	8	83	pepper	Fasolada
664	9	119	walnuts	Baklava
665	107	39	eggs	Pancakes
666	222	85	pie crust	Spinach Quiche
667	137	72	olive oil	Beef Lasagna
668	212	102	soy sauce	Chicken Parmesan
669	191	11	bell peppers	Seafood Paella
670	210	22	cheese	Chicken Alfredo
671	187	111	tomatoes	Tomato Soup
672	4	74	onion	Spanakopita
673	89	43	garlic	Moussaka
674	137	43	garlic	Beef Lasagna
675	183	11	bell peppers	Thai Green Curry
676	229	12	bread	French Toast
677	209	43	garlic	Chicken and Rice
678	130	42	flour	Chicken Parmesan
679	129	16	butter	Mashed Potatoes
680	172	83	pepper	Scrambled Eggs
681	10	57	lemon juice	Avgolemono Soup
682	206	115	vanilla	French Toast
683	158	111	tomatoes	Chicken Parmesan
684	208	16	butter	Scrambled Eggs
685	9	120	water	Baklava
686	214	39	eggs	Egg Fried Rice
687	201	22	cheese	Loaded Baked Potato
688	1	62	milk	Moussaka
689	200	103	spinach	Spinach Quiche
690	192	43	garlic	Beef Lasagna
691	111	83	pepper	Spinach Quiche
692	154	111	tomatoes	Tomato Soup
693	192	83	pepper	Beef Lasagna
694	171	83	pepper	Mashed Potatoes
695	207	16	butter	Buttered Toast
696	166	89	potatoes	Loaded Baked Potato
697	152	6	bamboo shoots	Thai Green Curry
698	166	16	butter	Loaded Baked Potato
699	159	12	bread	Buttered Toast
700	190	97	salt	Vegetable Stir Fry
701	111	62	milk	Spinach Quiche
702	122	43	garlic	Chicken Parmesan
703	189	5	balsamic vinegar	Caprese Salad
704	222	39	eggs	Spinach Quiche
705	165	83	pepper	Beef Lasagna
706	10	23	chicken	Avgolemono Soup
707	12	80	parsley	Gigantes Plaki
708	199	72	olive oil	Garlic Bread
709	152	48	green curry paste	Thai Green Curry
710	161	83	pepper	Cheese Omelette
711	198	101	sour cream	Fish Tacos
712	30	34	croutons	Caesar Salad
713	187	16	butter	Tomato Soup
714	90	114	tzatziki	Souvlaki
715	151	81	pasta	Carbonara Pasta
716	143	72	olive oil	Caprese Salad
717	195	16	butter	Grilled Cheese
718	146	22	cheese	Chicken Alfredo
719	224	43	garlic	Chicken Parmesan
720	91	62	milk	Tiropita
721	146	83	pepper	Chicken Alfredo
723	196	5	balsamic vinegar	Caprese Salad
724	12	43	garlic	Gigantes Plaki
725	164	56	lemon	Seafood Paella
726	182	76	oregano	Beef Lasagna
727	197	16	butter	Tomato Soup
728	137	76	oregano	Beef Lasagna
729	151	83	pepper	Carbonara Pasta
730	225	22	cheese	Chicken Caesar Salad
731	179	93	rice	Mushroom Risotto
732	128	12	bread	Buttered Toast
733	10	20	carrots	Avgolemono Soup
734	117	53	hot sauce	Fish Tacos
735	10	39	eggs	Avgolemono Soup
736	27	78	parmesan	Caesar Salad
737	103	81	pasta	Bob's Demo Pasta
738	200	83	pepper	Spinach Quiche
739	198	122	white fish	Fish Tacos
740	219	39	eggs	Cheese Omelette
741	202	43	garlic	Simple Pasta
742	141	12	bread	Garlic Bread
743	165	22	cheese	Beef Lasagna
744	170	97	salt	Carbonara Pasta
745	17	74	onion	Kleftiko
746	153	61	lime	Fish Tacos
747	27	18	caesar dressing	Caesar Salad
749	219	16	butter	Cheese Omelette
750	201	2	bacon	Loaded Baked Potato
751	107	16	butter	Pancakes
752	225	60	lettuce	Chicken Caesar Salad
753	226	16	butter	Grilled Cheese
754	204	102	soy sauce	Egg Fried Rice
755	204	97	salt	Egg Fried Rice
756	232	72	olive oil	Carbonara Pasta
757	125	83	pepper	Tomato Soup
758	208	83	pepper	Scrambled Eggs
759	120	101	sour cream	Loaded Baked Potato
760	173	27	cilantro	Fish Tacos
761	149	85	pie crust	Spinach Quiche
762	107	115	vanilla	Pancakes
763	183	6	bamboo shoots	Thai Green Curry
764	140	39	eggs	Cheese Omelette
765	1	28	cinnamon	Moussaka
766	223	43	garlic	Scrambled Eggs
767	230	97	salt	Chicken and Rice
768	149	83	pepper	Spinach Quiche
770	225	18	caesar dressing	Chicken Caesar Salad
771	28	101	sour cream	Beef Tacos
772	131	72	olive oil	Grilled Cheese
773	211	62	milk	Cheese Omelette
779	132	111	tomatoes	Fresh Salad
780	196	65	mozzarella	Caprese Salad
781	196	7	basil	Caprese Salad
782	163	39	eggs	Egg Fried Rice
783	209	97	salt	Chicken and Rice
784	139	43	garlic	Chicken and Rice
785	108	3	baking powder	Pancakes
786	14	39	eggs	Galaktoboureko
787	7	35	cucumber	Tzatziki
788	121	39	eggs	Scrambled Eggs
789	2	114	tzatziki	Souvlaki
790	92	21	celery	Psarosoupa
791	91	39	eggs	Tiropita
792	166	2	bacon	Loaded Baked Potato
793	144	100	shrimp	Seafood Paella
794	2	88	pork shoulder	Souvlaki
795	31	111	tomatoes	Beef Tacos
796	168	65	mozzarella	Caprese Salad
797	228	72	olive oil	Seafood Paella
798	228	11	bell peppers	Seafood Paella
799	163	72	olive oil	Egg Fried Rice
800	138	97	salt	Tomato Soup
801	189	111	tomatoes	Caprese Salad
802	130	72	olive oil	Chicken Parmesan
803	216	62	milk	Tomato Soup
804	158	7	basil	Chicken Parmesan
805	144	95	saffron	Seafood Paella
806	4	72	olive oil	Spanakopita
807	158	13	bread crumbs	Chicken Parmesan
808	211	39	eggs	Cheese Omelette
809	4	83	pepper	Spanakopita
810	232	43	garlic	Carbonara Pasta
811	190	43	garlic	Vegetable Stir Fry
812	175	16	butter	Buttered Toast
813	152	11	bell peppers	Thai Green Curry
814	166	22	cheese	Loaded Baked Potato
815	132	97	salt	Fresh Salad
816	133	39	eggs	Egg Fried Rice
817	164	43	garlic	Seafood Paella
818	12	83	pepper	Gigantes Plaki
819	144	11	bell peppers	Seafood Paella
820	195	12	bread	Grilled Cheese
821	31	60	lettuce	Beef Tacos
822	162	85	pie crust	Spinach Quiche
823	9	16	butter	Baklava
824	225	34	croutons	Chicken Caesar Salad
825	174	16	butter	Cheese Omelette
826	121	97	salt	Scrambled Eggs
827	89	79	parmesan cheese	Moussaka
828	169	24	chicken breast	Chicken and Rice
829	5	46	grape leaves	Dolmades
830	173	53	hot sauce	Fish Tacos
831	146	43	garlic	Chicken Alfredo
832	117	101	sour cream	Fish Tacos
833	120	83	pepper	Loaded Baked Potato
834	13	80	parsley	Keftedes
835	157	97	salt	Vegetable Stir Fry
836	134	83	pepper	Chicken Alfredo
837	224	97	salt	Chicken Parmesan
838	186	97	salt	Garlic Bread
839	114	62	milk	French Toast
840	187	62	milk	Tomato Soup
841	130	43	garlic	Chicken Parmesan
842	151	72	olive oil	Carbonara Pasta
843	231	16	butter	Buttered Toast
844	213	89	potatoes	Beef Lasagna
845	232	83	pepper	Carbonara Pasta
846	114	115	vanilla	French Toast
847	28	96	salsa	Beef Tacos
848	4	84	phyllo dough	Spanakopita
849	4	37	dill	Spanakopita
850	142	34	croutons	Chicken Caesar Salad
851	137	81	pasta	Beef Lasagna
852	134	42	flour	Chicken Alfredo
853	140	62	milk	Cheese Omelette
854	150	50	ground beef	Mashed Potatoes
855	3	40	feta cheese	Greek Salad (Horiatiki)
856	6	39	eggs	Pastitsio
857	6	74	onion	Pastitsio
858	167	83	pepper	Scrambled Eggs
859	146	16	butter	Chicken Alfredo
860	118	48	green curry paste	Thai Green Curry
861	2	43	garlic	Souvlaki
862	210	62	milk	Chicken Alfredo
863	170	39	eggs	Carbonara Pasta
864	135	39	eggs	Vegetable Stir Fry
865	160	97	salt	Simple Pasta
867	219	97	salt	Cheese Omelette
868	188	43	garlic	Carbonara Pasta
869	131	23	chicken	Grilled Cheese
870	221	97	salt	Caprese Salad
871	14	84	phyllo dough	Galaktoboureko
872	123	72	olive oil	Chicken and Rice
873	203	83	pepper	Mashed Potatoes
874	4	39	eggs	Spanakopita
875	173	17	cabbage	Fish Tacos
876	136	72	olive oil	Simple Pasta
877	179	22	cheese	Mushroom Risotto
878	182	83	pepper	Beef Lasagna
879	202	97	salt	Simple Pasta
880	92	37	dill	Psarosoupa
881	141	16	butter	Garlic Bread
882	188	72	olive oil	Carbonara Pasta
883	230	93	rice	Chicken and Rice
884	147	16	butter	Buttered Toast
885	214	97	salt	Egg Fried Rice
886	17	89	potatoes	Kleftiko
887	151	97	salt	Carbonara Pasta
888	174	22	cheese	Cheese Omelette
889	110	83	pepper	Chicken Alfredo
890	144	67	mussels	Seafood Paella
893	170	2	bacon	Carbonara Pasta
894	129	83	pepper	Mashed Potatoes
895	14	62	milk	Galaktoboureko
896	133	93	rice	Egg Fried Rice
897	188	39	eggs	Carbonara Pasta
898	222	103	spinach	Spinach Quiche
899	218	89	potatoes	Thai Green Curry
900	211	83	pepper	Cheese Omelette
901	118	24	chicken breast	Thai Green Curry
903	84	29	cinnamon stick	Stifado
904	180	22	cheese	Spinach Quiche
905	189	7	basil	Caprese Salad
906	92	83	pepper	Psarosoupa
907	147	95	saffron	Buttered Toast
908	152	107	thai basil	Thai Green Curry
909	175	12	bread	Buttered Toast
910	111	103	spinach	Spinach Quiche
911	25	70	oil	Chicken Stir Fry
912	199	97	salt	Garlic Bread
913	222	113	truffle oil	Spinach Quiche
915	6	68	nutmeg	Pastitsio
916	209	24	chicken breast	Chicken and Rice
917	209	83	pepper	Chicken and Rice
918	144	106	tahini	Seafood Paella
919	210	97	salt	Chicken Alfredo
920	29	39	eggs	Pancakes
922	3	91	red onion	Greek Salad (Horiatiki)
923	8	121	white beans	Fasolada
924	205	72	olive oil	Vegetable Stir Fry
925	187	97	salt	Tomato Soup
926	109	22	cheese	Mushroom Risotto
927	163	102	soy sauce	Egg Fried Rice
932	179	72	olive oil	Mushroom Risotto
933	15	43	garlic	Melitzanosalata
934	157	72	olive oil	Vegetable Stir Fry
935	180	97	salt	Spinach Quiche
936	170	22	cheese	Carbonara Pasta
937	118	107	thai basil	Thai Green Curry
938	216	64	miso paste	Tomato Soup
939	140	16	butter	Cheese Omelette
940	205	97	salt	Vegetable Stir Fry
941	183	48	green curry paste	Thai Green Curry
942	185	97	salt	Fresh Salad
943	170	83	pepper	Carbonara Pasta
944	149	39	eggs	Spinach Quiche
945	148	72	olive oil	Fresh Salad
946	9	52	honey	Baklava
947	138	111	tomatoes	Tomato Soup
948	137	83	pepper	Beef Lasagna
949	152	41	fish sauce	Thai Green Curry
951	157	83	pepper	Vegetable Stir Fry
952	197	97	salt	Tomato Soup
953	24	22	cheese	Grilled Cheese Sandwich
954	120	97	salt	Loaded Baked Potato
955	122	72	olive oil	Chicken Parmesan
956	12	111	tomatoes	Gigantes Plaki
957	164	80	parsley	Seafood Paella
958	165	76	oregano	Beef Lasagna
959	115	43	garlic	Garlic Bread
960	220	89	potatoes	Mashed Potatoes
961	137	7	basil	Beef Lasagna
962	90	83	pepper	Souvlaki
963	13	72	olive oil	Keftedes
964	4	103	spinach	Spanakopita
965	111	22	cheese	Spinach Quiche
966	89	28	cinnamon	Moussaka
967	111	97	salt	Spinach Quiche
968	190	20	carrots	Vegetable Stir Fry
969	180	83	pepper	Spinach Quiche
971	105	34	croutons	Caesar Salad
972	6	72	olive oil	Pastitsio
973	218	81	pasta	Thai Green Curry
974	120	89	potatoes	Loaded Baked Potato
975	129	62	milk	Mashed Potatoes
976	106	96	salsa	Beef Tacos
977	118	41	fish sauce	Thai Green Curry
978	26	7	basil	Tomato Soup
979	134	16	butter	Chicken Alfredo
980	219	62	milk	Cheese Omelette
981	215	83	pepper	Loaded Baked Potato
982	84	72	olive oil	Stifado
983	160	43	garlic	Simple Pasta
984	107	62	milk	Pancakes
985	141	72	olive oil	Garlic Bread
986	188	2	bacon	Carbonara Pasta
987	106	50	ground beef	Beef Tacos
988	17	111	tomatoes	Kleftiko
989	194	22	cheese	Chicken Parmesan
990	127	103	spinach	Spinach Quiche
991	144	43	garlic	Seafood Paella
992	181	22	cheese	Chicken Caesar Salad
993	151	2	bacon	Carbonara Pasta
994	187	83	pepper	Tomato Soup
995	10	97	salt	Avgolemono Soup
996	149	22	cheese	Spinach Quiche
997	91	83	pepper	Tiropita
998	166	97	salt	Loaded Baked Potato
999	183	24	chicken breast	Thai Green Curry
1000	224	24	chicken breast	Chicken Parmesan
1001	178	12	bread	French Toast
1003	106	105	taco shells	Beef Tacos
1004	109	66	mushrooms	Mushroom Risotto
1005	5	83	pepper	Dolmades
1006	119	111	tomatoes	Caprese Salad
1007	126	39	eggs	Scrambled Eggs
1008	209	93	rice	Chicken and Rice
1009	132	90	quinoa	Fresh Salad
1010	15	97	salt	Melitzanosalata
1011	16	42	flour	Loukoumades
1012	90	57	lemon juice	Souvlaki
1013	12	109	tomato paste	Gigantes Plaki
1014	158	42	flour	Chicken Parmesan
1015	92	72	olive oil	Psarosoupa
1016	108	115	vanilla	Pancakes
1017	174	97	salt	Cheese Omelette
1018	151	39	eggs	Carbonara Pasta
1019	193	24	chicken breast	Chicken Caesar Salad
1020	221	7	basil	Caprese Salad
1021	30	78	parmesan	Caesar Salad
1022	106	111	tomatoes	Beef Tacos
1023	9	28	cinnamon	Baklava
1024	100	72	olive oil	Bob's Demo Pasta
1025	153	53	hot sauce	Fish Tacos
1026	157	11	bell peppers	Vegetable Stir Fry
1027	110	43	garlic	Chicken Alfredo
1028	114	12	bread	French Toast
1029	14	16	butter	Galaktoboureko
1030	10	83	pepper	Avgolemono Soup
1031	9	57	lemon juice	Baklava
1032	168	72	olive oil	Caprese Salad
1033	112	72	olive oil	Seafood Paella
1034	213	11	bell peppers	Beef Lasagna
1035	16	119	walnuts	Loukoumades
1036	1	83	pepper	Moussaka
1037	129	95	saffron	Mashed Potatoes
1038	214	93	rice	Egg Fried Rice
1039	114	16	butter	French Toast
1040	90	72	olive oil	Souvlaki
1041	221	5	balsamic vinegar	Caprese Salad
1042	116	22	cheese	Carbonara Pasta
1043	118	11	bell peppers	Thai Green Curry
1044	92	97	salt	Psarosoupa
1045	106	101	sour cream	Beef Tacos
1046	229	104	sugar	French Toast
1047	14	52	honey	Galaktoboureko
1048	110	81	pasta	Chicken Alfredo
1049	217	93	rice	Mushroom Risotto
1050	142	18	caesar dressing	Chicken Caesar Salad
1051	225	95	saffron	Chicken Caesar Salad
1052	26	33	cream	Tomato Soup
1054	5	93	rice	Dolmades
1055	6	81	pasta	Pastitsio
1057	16	28	cinnamon	Loukoumades
1058	217	72	olive oil	Mushroom Risotto
1060	109	16	butter	Mushroom Risotto
1061	28	111	tomatoes	Beef Tacos
1062	109	123	white wine	Mushroom Risotto
1063	150	62	milk	Mashed Potatoes
1064	116	43	garlic	Carbonara Pasta
1065	229	16	butter	French Toast
1066	212	45	ginger	Chicken Parmesan
1067	7	97	salt	Tzatziki
1068	26	16	butter	Tomato Soup
1069	216	97	salt	Tomato Soup
1070	17	43	garlic	Kleftiko
1071	147	106	tahini	Buttered Toast
1072	115	97	salt	Garlic Bread
1073	113	16	butter	Buttered Toast
1074	27	60	lettuce	Caesar Salad
1075	10	74	onion	Avgolemono Soup
1076	198	112	tortillas	Fish Tacos
1077	120	2	bacon	Loaded Baked Potato
1078	16	97	salt	Loukoumades
1079	1	42	flour	Moussaka
1080	158	72	olive oil	Chicken Parmesan
1081	199	16	butter	Garlic Bread
1082	6	79	parmesan cheese	Pastitsio
1084	9	30	cloves	Baklava
1085	84	10	beef	Stifado
1086	157	43	garlic	Vegetable Stir Fry
1087	117	61	lime	Fish Tacos
1088	211	22	cheese	Cheese Omelette
1089	158	43	garlic	Chicken Parmesan
1090	2	97	salt	Souvlaki
1091	26	111	tomatoes	Tomato Soup
1093	121	16	butter	Scrambled Eggs
1094	124	97	salt	Mashed Potatoes
1095	84	43	garlic	Stifado
1096	162	62	milk	Spinach Quiche
1097	123	93	rice	Chicken and Rice
1098	197	83	pepper	Tomato Soup
1099	133	97	salt	Egg Fried Rice
1100	153	101	sour cream	Fish Tacos
1101	148	97	salt	Fresh Salad
1102	127	83	pepper	Spinach Quiche
1103	182	7	basil	Beef Lasagna
1104	132	95	saffron	Fresh Salad
1105	218	62	milk	Thai Green Curry
1106	207	12	bread	Buttered Toast
1107	127	85	pie crust	Spinach Quiche
1108	225	24	chicken breast	Chicken Caesar Salad
1109	156	34	croutons	Chicken Caesar Salad
1110	232	81	pasta	Carbonara Pasta
1111	107	3	baking powder	Pancakes
\.


--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: user_pantry; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_pantry (id, user_id, created_at, ingredient_id, ingredient_name) FROM stdin;
234	1	2025-10-03 10:34:25.771191+02	33	cream
236	10	2025-10-03 10:34:25.785002+02	81	pasta
237	10	2025-10-03 10:34:25.785002+02	39	eggs
238	15	2025-10-03 10:05:56.187005+02	93	rice
239	15	2025-10-03 10:05:56.187005+02	81	pasta
241	15	2025-10-03 10:05:56.187005+02	43	garlic
242	8	2025-10-03 10:34:25.778731+02	59	lentils
243	8	2025-10-03 10:34:25.778731+02	98	seeds
244	2	2025-09-29 01:37:31.583683+02	62	milk
245	1	2025-10-03 10:34:25.771191+02	42	flour
246	15	2025-10-03 10:05:56.187005+02	22	cheese
247	1	2025-10-03 10:34:25.771191+02	16	butter
248	8	2025-10-03 10:34:25.778731+02	72	olive oil
249	8	2025-10-03 10:34:25.778731+02	90	quinoa
250	10	2025-10-03 10:34:25.785002+02	42	flour
251	4	2025-09-29 01:37:31.583683+02	111	tomatoes
252	8	2025-10-03 10:34:25.778731+02	81	pasta
253	10	2025-10-03 10:34:25.785002+02	7	basil
254	9	2025-10-03 10:34:25.782748+02	97	salt
255	15	2025-10-03 10:05:56.187005+02	83	pepper
256	9	2025-10-03 10:34:25.782748+02	72	olive oil
257	4	2025-09-29 01:37:31.583683+02	102	soy sauce
258	8	2025-10-03 10:34:25.778731+02	25	chickpeas
259	4	2025-09-29 01:37:31.583683+02	72	olive oil
260	8	2025-10-03 10:34:25.778731+02	117	vegetables
261	5	2025-09-29 01:37:31.583683+02	50	ground beef
262	8	2025-10-03 10:34:25.778731+02	93	rice
263	1	2025-10-03 10:34:25.771191+02	125	yeast
264	5	2025-09-29 01:37:31.583683+02	42	flour
265	9	2025-10-03 10:34:25.782748+02	42	flour
266	2	2025-09-29 01:37:31.583683+02	43	garlic
267	8	2025-10-03 10:34:25.778731+02	39	eggs
268	15	2025-10-03 10:05:56.187005+02	42	flour
269	1	2025-10-03 10:34:25.771191+02	104	sugar
270	5	2025-09-29 01:37:31.583683+02	16	butter
271	8	2025-10-03 10:34:25.778731+02	69	nuts
272	10	2025-10-03 10:34:25.785002+02	65	mozzarella
273	10	2025-10-03 10:34:25.785002+02	43	garlic
274	4	2025-09-29 01:37:31.583683+02	62	milk
275	15	2025-10-03 10:05:56.187005+02	89	potatoes
276	9	2025-10-03 10:34:25.782748+02	65	mozzarella
277	10	2025-10-03 10:34:25.785002+02	22	cheese
278	9	2025-10-03 10:34:25.782748+02	39	eggs
279	4	2025-09-29 01:37:31.583683+02	22	cheese
280	15	2025-10-03 10:05:56.187005+02	16	butter
281	4	2025-09-29 01:37:31.583683+02	16	butter
282	15	2025-10-03 10:05:56.187005+02	24	chicken breast
283	8	2025-10-03 10:34:25.778731+02	62	milk
284	1	2025-10-03 10:34:25.771191+02	115	vanilla
285	15	2025-10-03 10:05:56.187005+02	60	lettuce
286	15	2025-10-03 10:05:56.187005+02	72	olive oil
287	9	2025-10-03 10:34:25.782748+02	111	tomatoes
288	10	2025-10-03 10:34:25.785002+02	97	salt
289	8	2025-10-03 10:34:25.778731+02	103	spinach
290	9	2025-10-03 10:34:25.782748+02	124	wine vinegar
291	10	2025-10-03 10:34:25.785002+02	56	lemon
293	10	2025-10-03 10:34:25.785002+02	12	bread
294	8	2025-10-03 10:34:25.778731+02	11	bell peppers
295	8	2025-10-03 10:34:25.778731+02	66	mushrooms
296	1	2025-10-03 10:34:25.771191+02	68	nutmeg
297	2	2025-09-29 01:37:31.583683+02	93	rice
298	1	2025-10-03 10:34:25.771191+02	52	honey
299	8	2025-10-03 10:34:25.778731+02	56	lemon
300	8	2025-10-03 10:34:25.778731+02	111	tomatoes
301	10	2025-10-03 10:34:25.785002+02	111	tomatoes
302	9	2025-10-03 10:34:25.782748+02	81	pasta
303	10	2025-10-03 10:34:25.785002+02	73	olives
304	9	2025-10-03 10:34:25.782748+02	24	chicken breast
305	9	2025-10-03 10:34:25.782748+02	80	parsley
307	15	2025-10-03 10:05:56.187005+02	104	sugar
308	2	2025-09-29 01:37:31.583683+02	45	ginger
309	9	2025-10-03 10:34:25.782748+02	19	capers
310	10	2025-10-03 10:34:25.785002+02	76	oregano
311	1	2025-10-03 10:34:25.771191+02	97	salt
312	15	2025-10-03 10:05:56.187005+02	20	carrots
313	1	2025-10-03 10:34:25.771191+02	26	chocolate chips
314	10	2025-10-03 10:34:25.785002+02	124	wine vinegar
315	5	2025-09-29 01:37:31.583683+02	62	milk
316	2	2025-09-29 01:37:31.583683+02	102	soy sauce
317	5	2025-09-29 01:37:31.583683+02	22	cheese
318	2	2025-09-29 01:37:31.583683+02	39	eggs
319	4	2025-09-29 01:37:31.583683+02	81	pasta
320	9	2025-10-03 10:34:25.782748+02	73	olives
321	10	2025-10-03 10:34:25.785002+02	19	capers
322	4	2025-09-29 01:37:31.583683+02	93	rice
323	4	2025-09-29 01:37:31.583683+02	42	flour
324	2	2025-09-29 01:37:31.583683+02	16	butter
325	4	2025-09-29 01:37:31.583683+02	39	eggs
326	1	2025-10-03 10:34:25.771191+02	39	eggs
327	8	2025-10-03 10:34:25.778731+02	42	flour
328	10	2025-10-03 10:34:25.785002+02	80	parsley
329	9	2025-10-03 10:34:25.782748+02	83	pepper
330	1	2025-10-03 10:34:25.771191+02	62	milk
331	15	2025-10-03 10:05:56.187005+02	62	milk
332	1	2025-10-03 10:34:25.771191+02	116	vegetable oil
333	4	2025-09-29 01:37:31.583683+02	43	garlic
334	1	2025-10-03 10:34:25.771191+02	28	cinnamon
335	8	2025-10-03 10:34:25.778731+02	22	cheese
336	2	2025-09-29 01:37:31.583683+02	42	flour
337	8	2025-10-03 10:34:25.778731+02	9	beans
338	1	2025-10-03 10:34:25.771191+02	15	brown sugar
339	9	2025-10-03 10:34:25.782748+02	7	basil
340	10	2025-10-03 10:34:25.785002+02	11	bell peppers
341	9	2025-10-03 10:34:25.782748+02	76	oregano
342	5	2025-09-29 01:37:31.583683+02	60	lettuce
343	1	2025-10-03 10:34:25.771191+02	4	baking soda
344	4	2025-09-29 01:37:31.583683+02	45	ginger
345	1	2025-10-03 10:34:25.771191+02	31	cocoa powder
346	4	2025-09-29 01:37:31.583683+02	23	chicken
347	15	2025-10-03 10:05:56.187005+02	111	tomatoes
348	8	2025-10-03 10:34:25.778731+02	43	garlic
349	2	2025-09-29 01:37:31.583683+02	72	olive oil
350	9	2025-10-03 10:34:25.782748+02	12	bread
351	2	2025-09-29 01:37:31.583683+02	111	tomatoes
352	15	2025-10-03 10:05:56.187005+02	97	salt
354	2	2025-09-29 01:37:31.583683+02	23	chicken
355	9	2025-10-03 10:34:25.782748+02	43	garlic
356	2	2025-09-29 01:37:31.583683+02	81	pasta
357	1	2025-10-03 10:34:25.771191+02	3	baking powder
358	10	2025-10-03 10:34:25.785002+02	83	pepper
359	10	2025-10-03 10:34:25.785002+02	72	olive oil
360	15	2025-10-03 10:05:56.187005+02	39	eggs
361	5	2025-09-29 01:37:31.583683+02	39	eggs
362	8	2025-10-03 10:34:25.778731+02	108	tofu
364	15	2025-10-03 10:05:56.187005+02	11	bell peppers
365	15	2025-10-03 10:05:56.187005+02	12	bread
366	2	2025-09-29 01:37:31.583683+02	22	cheese
367	9	2025-10-03 10:34:25.782748+02	22	cheese
368	9	2025-10-03 10:34:25.782748+02	56	lemon
369	9	2025-10-03 10:34:25.782748+02	11	bell peppers
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, username, role, password_hash, created_at, updated_at) FROM stdin;
1	admin@recipe-pantry.com	admin	admin	$2b$12$Hx4iZ86GEEGFRZFKz3GxB.XTDm0rromf1xTgvHuqjPW1SZBrTWZiC	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
10	admin-two@recipe-pantry.com	admin-two	admin	$2b$12$yS7mjJH742S/PsHU4XlzSu/JYEfuLOYIELuqQeJy7lk.E2IX5.YGy	2025-09-29 02:00:17.539719+02	2025-09-29 02:00:17.539719+02
2	manos@masterschool.com	manos	user	$2b$12$SH/6G35Wi6dNUscfdaf6uOKPdh5oaO7mcVVcZOALx47H6ePnZ1Cta	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
15	alice@demo.com	alice	user	$2b$12$HRdmLbpRT8lx8X.IZ3Kly.trmgmWvYmsXqGkMi6FkrwYBcjgrlL4C	2025-09-30 14:43:04.376866+02	2025-09-30 14:43:04.376866+02
4	bob@demo.com	bob	user	$2b$12$kFsLe1pi8YA9vapXM9OaAuz0C8dnkJ20MUtR1oE9KtVTYmnX5b4VS	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
5	charlie@demo.com	charlie	user	$2b$12$BLZ3t5B24CSPKBRtRKGLTOsThFtwSZ7aABVlNyBMqMi4tlkK/hb9S	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
8	user1_new@example.com	use1_nu	user	$2b$12$Wl.48Pkt7NhYga/N5pkG/ujhk61u57Z9lADVmMHx1CzoMVA.YoMYG	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
9	3trees@example.com	treesfor3	user	$2b$12$d442pv3/C7yY7J4ab0E9GuWuPAHOtGO7J3y8UjgbvdPIw0Oi995rC	2025-09-29 01:37:31.567894+02	2025-09-29 01:37:31.567894+02
\.


--
-- Name: ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ingredients_id_seq', 2386, true);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 3347, true);


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recipes_id_seq', 878, true);


--
-- Name: user_pantry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_pantry_id_seq', 1476, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 460, true);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: ingredients unique_ingredient_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT unique_ingredient_name UNIQUE (name);


--
-- Name: recipe_ingredients unique_recipe_ingredient; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT unique_recipe_ingredient UNIQUE (recipe_id, ingredient_id);


--
-- Name: recipes unique_recipe_title_per_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT unique_recipe_title_per_user UNIQUE (user_id, title);


--
-- Name: user_pantry unique_user_ingredient; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT unique_user_ingredient UNIQUE (user_id, ingredient_id);


--
-- Name: user_pantry user_pantry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_ingredients_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ingredients_name ON public.ingredients USING btree (name);


--
-- Name: idx_recipe_ingredients_ingredient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipe_ingredients_ingredient_id ON public.recipe_ingredients USING btree (ingredient_id);


--
-- Name: idx_recipe_ingredients_recipe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipe_ingredients_recipe_id ON public.recipe_ingredients USING btree (recipe_id);


--
-- Name: idx_recipes_is_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipes_is_public ON public.recipes USING btree (is_public);


--
-- Name: idx_recipes_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recipes_user_id ON public.recipes USING btree (user_id);


--
-- Name: idx_user_pantry_ingredient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_pantry_ingredient_id ON public.user_pantry USING btree (ingredient_id);


--
-- Name: idx_user_pantry_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_pantry_user_id ON public.user_pantry USING btree (user_id);


--
-- Name: recipe_ingredients recipe_ingredients_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: recipe_ingredients recipe_ingredients_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- Name: recipes recipes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_pantry user_pantry_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- Name: user_pantry user_pantry_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pantry
    ADD CONSTRAINT user_pantry_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict XqlD6W1QKFfAg7iXsV5XlP998chitZ9ZkDgBm54WhVGemFudSYeAKcB8o1hIBFF
