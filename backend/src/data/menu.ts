export interface MenuItem {
  id: string;
  name: string;
  category: 'snacks' | 'drinks' | 'combos';
  price: number | null;
  portion: string;
  badge?: string;
  description: string;
  isActive: boolean;
}

export const SHARED_MENU: MenuItem[] = [
  // Snacks (4 with confirmed price + 1 Chowmein Spring Roll configurable)
  {
    id: 'spring_roll',
    name: 'Veg Spring Roll',
    category: 'snacks',
    price: 60,
    portion: '/ 2 pcs',
    badge: 'Crispy Veg',
    description: 'Golden-fried handmade pastry rolls stuffed with shredded cabbage, carrots, and sweet bell peppers.',
    isActive: true,
  },
  {
    id: 'chowmein_spring_roll',
    name: 'Chowmein Spring Roll',
    category: 'snacks',
    price: null, // Configurable by stall owner
    portion: '/ 2 pcs',
    badge: 'Special Treat',
    description: 'Crispy fried rolls bursting with spicy, wok-tossed Hakka noodles and scallions.',
    isActive: true,
  },
  {
    id: 'classic_fries',
    name: 'Classic Salted Fries',
    category: 'snacks',
    price: 70,
    portion: '/ portion',
    badge: 'Crispy Classic',
    description: 'Crispy golden potato fingers cut to perfection, double-fried for optimal crunch and tossed with fine sea salt.',
    isActive: true,
  },
  {
    id: 'cheese_fries',
    name: 'Loaded Cheese Fries',
    category: 'snacks',
    price: 100,
    portion: '/ loaded',
    badge: 'Bestseller',
    description: 'Crispy golden fries smothered in warm molten cheddar cheese sauce and garnished with chili seasoning flakes.',
    isActive: true,
  },
  {
    id: 'peri_peri_fries',
    name: 'Peri Peri Fries',
    category: 'snacks',
    price: 80,
    portion: '/ shaken',
    badge: 'Spicy Hot',
    description: 'Golden fries vigorously tossed in authentic African bird-eye chili peri peri dust.',
    isActive: true,
  },

  // Active Chill O'Clock Drinks (5 items)
  {
    id: 'blue_lagoon',
    name: 'Blue Lagoon',
    category: 'drinks',
    price: 50,
    portion: '/ 350ml',
    badge: 'Signature Chill',
    description: 'Electric blue citrus mocktail infused with blue curaçao syrup, bubbly soda, fresh mint leaves, and a lemon wedge.',
    isActive: true,
  },
  {
    id: 'green_apple',
    name: 'Green Apple',
    category: 'drinks',
    price: 50,
    portion: '/ 350ml',
    badge: 'Tangy Sips',
    description: 'Crisp and tart Granny Smith apple mocktail, carbonated and poured over crystal ice with apple slices.',
    isActive: true,
  },
  {
    id: 'watermelon',
    name: 'Watermelon Cooler',
    category: 'drinks',
    price: 50,
    portion: '/ 350ml',
    badge: 'Summer Favorite',
    description: 'Hydrating summer cooler made from sweet ripe watermelon syrup, sparkling fizz, and aromatic mint sprigs.',
    isActive: true,
  },
  {
    id: 'mint_mojito',
    name: 'Mint Mojito',
    category: 'drinks',
    price: 50,
    portion: '/ 350ml',
    badge: 'Classic Refresher',
    description: 'Freshly muddled mint leaves, tart lime wedges, cane sweetness, and effervescent sparkling soda.',
    isActive: true,
  },
  {
    id: 'cranberry',
    name: 'Cranberry Mojito',
    category: 'drinks',
    price: 50,
    portion: '/ 350ml',
    badge: 'Berry Burst',
    description: 'Deep ruby cooler combining tart cranberry notes, garden mint, and bubbly soda over crushed crystal ice.',
    isActive: true,
  },

  // Combos
  {
    id: 'classic_combo',
    name: 'Classic Combo',
    category: 'combos',
    price: 110,
    portion: 'Fries + Drink',
    badge: 'Save ₹10',
    description: 'Classic Salted Fries + Choice of Any Chilled Drink.',
    isActive: true,
  },
  {
    id: 'peri_peri_combo',
    name: 'Peri Peri Combo',
    category: 'combos',
    price: 120,
    portion: 'Fries + Drink',
    badge: 'Spicy Deal',
    description: 'Peri Peri Fries + Choice of Any Chilled Drink.',
    isActive: true,
  },
  {
    id: 'cheese_bomb_combo',
    name: 'Cheese Bomb Combo',
    category: 'combos',
    price: 140,
    portion: 'Fries + Drink',
    badge: 'Ultimate Treat',
    description: 'Loaded Cheese Fries + Choice of Any Chilled Drink.',
    isActive: true,
  },
  {
    id: 'roll_and_sip',
    name: 'Roll & Sip',
    category: 'combos',
    price: 100,
    portion: 'Rolls + Drink',
    badge: 'Best Value',
    description: 'Veg Spring Roll (2 pcs) + Choice of Any Chilled Drink.',
    isActive: true,
  },
];
