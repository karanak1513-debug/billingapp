export interface Product {
  id: string;
  name: string;
  category: 'snacks' | 'drinks';
  price: number | null; // null for "Price to be confirmed"
  portion: string;
  image: string;
  badge?: string;
  description: string;
  ingredients?: string[];
  isPopular?: boolean;
}

export interface Combo {
  id: string;
  name: string;
  price: number;
  originalPrice: number;
  savings: number;
  image: string;
  badge?: string;
  description: string;
  includedItems: string[];
}
