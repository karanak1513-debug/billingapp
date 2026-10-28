import React, { useState, useMemo } from 'react';
import { SNACKS, DRINKS, COMBOS } from '../data/menu';
import { Product, Combo } from '../types';
import { Search, Plus, Sparkles, Utensils, GlassWater, Layers, HelpCircle } from 'lucide-react';

interface MenuSectionProps {
  onAddProduct: (product: Product) => void;
  onAddCombo: (combo: Combo) => void;
}

export const MenuSection: React.FC<MenuSectionProps> = ({ onAddProduct, onAddCombo }) => {
  const [activeTab, setActiveTab] = useState<'all' | 'snacks' | 'drinks' | 'combos'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  // Combined product list based on filters
  const filteredItems = useMemo(() => {
    const q = searchQuery.toLowerCase().trim();

    let items: Array<{ type: 'product'; data: Product } | { type: 'combo'; data: Combo }> = [];

    if (activeTab === 'all' || activeTab === 'snacks') {
      items.push(...SNACKS.map((p) => ({ type: 'product' as const, data: p })));
    }
    if (activeTab === 'all' || activeTab === 'drinks') {
      items.push(...DRINKS.map((p) => ({ type: 'product' as const, data: p })));
    }
    if (activeTab === 'all' || activeTab === 'combos') {
      items.push(...COMBOS.map((c) => ({ type: 'combo' as const, data: c })));
    }

    if (q) {
      items = items.filter((item) =>
        item.data.name.toLowerCase().includes(q) ||
        item.data.description.toLowerCase().includes(q) ||
        (item.data.badge && item.data.badge.toLowerCase().includes(q))
      );
    }

    return items;
  }, [activeTab, searchQuery]);

  return (
    <section id="menu" className="py-20 bg-cream relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center max-w-2xl mx-auto mb-12">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-caramel/20 border border-caramel/40 text-burgundy text-xs font-bold uppercase tracking-wider mb-3">
            <Utensils className="w-3.5 h-3.5 text-terracotta" />
            <span>Handcrafted Stall Menu</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-burgundy tracking-tight">
            Our Food & Drinks Catalogue
          </h2>
          <p className="mt-3 text-base text-espresso/80">
            Freshly prepared snacks and ice-cold mocktails. Every item is 100% vegetarian, served with love and festival energy.
          </p>
        </div>

        {/* Filter Tabs and Search Bar Bar */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-4 mb-10 pb-6 border-b border-caramel/20">
          
          {/* Category Tabs */}
          <div className="flex flex-wrap items-center justify-center gap-2">
            <button
              onClick={() => setActiveTab('all')}
              className={`px-4 py-2 rounded-full font-bold text-xs sm:text-sm transition-all flex items-center gap-1.5 ${
                activeTab === 'all'
                  ? 'bg-burgundy text-white shadow-md'
                  : 'bg-white text-espresso/70 hover:bg-white/80 border border-caramel/30'
              }`}
            >
              <Layers className="w-3.5 h-3.5" />
              <span>All Items</span>
              <span className="text-[10px] opacity-75">({SNACKS.length + DRINKS.length + COMBOS.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('snacks')}
              className={`px-4 py-2 rounded-full font-bold text-xs sm:text-sm transition-all flex items-center gap-1.5 ${
                activeTab === 'snacks'
                  ? 'bg-burgundy text-white shadow-md'
                  : 'bg-white text-espresso/70 hover:bg-white/80 border border-caramel/30'
              }`}
            >
              <Utensils className="w-3.5 h-3.5 text-terracotta" />
              <span>Crispy Snacks</span>
              <span className="text-[10px] opacity-75">({SNACKS.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('drinks')}
              className={`px-4 py-2 rounded-full font-bold text-xs sm:text-sm transition-all flex items-center gap-1.5 ${
                activeTab === 'drinks'
                  ? 'bg-burgundy text-white shadow-md'
                  : 'bg-white text-espresso/70 hover:bg-white/80 border border-caramel/30'
              }`}
            >
              <GlassWater className="w-3.5 h-3.5 text-blue-500" />
              <span>Chill O'Clock Drinks</span>
              <span className="text-[10px] opacity-75">({DRINKS.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('combos')}
              className={`px-4 py-2 rounded-full font-bold text-xs sm:text-sm transition-all flex items-center gap-1.5 ${
                activeTab === 'combos'
                  ? 'bg-burgundy text-white shadow-md'
                  : 'bg-white text-espresso/70 hover:bg-white/80 border border-caramel/30'
              }`}
            >
              <Sparkles className="w-3.5 h-3.5 text-golden" />
              <span>Combos</span>
              <span className="text-[10px] opacity-75">({COMBOS.length})</span>
            </button>
          </div>

          {/* Search Box */}
          <div className="relative w-full md:w-72">
            <Search className="w-4 h-4 text-espresso/50 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search fries, rolls, mocktails..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-white rounded-full text-xs sm:text-sm border border-caramel/40 focus:outline-none focus:ring-2 focus:ring-burgundy text-espresso shadow-sm"
            />
          </div>

        </div>

        {/* Product Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filteredItems.map((item, index) => {
            if (item.type === 'combo') {
              const combo = item.data;
              return (
                <div
                  key={`combo-${combo.id}-${index}`}
                  className="bg-white rounded-3xl border border-caramel/30 overflow-hidden shadow-warm hover:shadow-warm-lg hover:border-caramel transition-all flex flex-col justify-between group"
                >
                  <div>
                    <div className="relative aspect-[4/3] bg-gradient-to-b from-cream to-cream-warm/70 p-3 flex items-center justify-center overflow-hidden">
                      <img
                        src={combo.image}
                        alt={combo.name}
                        className="w-full h-full object-contain filter drop-shadow group-hover:scale-105 transition-transform"
                        loading="lazy"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = '/assets/food/classic_fries.png';
                        }}
                      />
                      <span className="absolute top-3 left-3 bg-golden text-burgundy text-[10px] font-black px-2.5 py-0.5 rounded-full uppercase shadow-sm">
                        Combo Deal
                      </span>
                    </div>

                    <div className="p-4 space-y-2">
                      <h3 className="font-display font-black text-lg text-burgundy">{combo.name}</h3>
                      <p className="text-xs text-espresso/70 line-clamp-2 leading-relaxed">{combo.description}</p>
                      <div className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded w-fit">
                        Save ₹{combo.savings}
                      </div>
                    </div>
                  </div>

                  <div className="p-4 pt-0 flex items-center justify-between border-t border-amber-50 mt-2">
                    <div>
                      <span className="text-xl font-black text-burgundy">₹{combo.price}</span>
                      <span className="text-xs text-espresso/40 line-through ml-1.5">₹{combo.originalPrice}</span>
                    </div>
                    <button
                      onClick={() => onAddCombo(combo)}
                      className="inline-flex items-center gap-1 bg-burgundy hover:bg-terracotta active:scale-95 text-white px-3 py-1.5 rounded-xl font-bold text-xs transition-colors shadow-sm"
                    >
                      <Plus className="w-3.5 h-3.5" />
                      <span>Add</span>
                    </button>
                  </div>
                </div>
              );
            }

            const product = item.data;
            const isConfirmedPrice = product.price !== null;

            return (
              <div
                key={`prod-${product.id}-${index}`}
                className="bg-white rounded-3xl border border-caramel/30 overflow-hidden shadow-warm hover:shadow-warm-lg hover:border-caramel transition-all flex flex-col justify-between group"
              >
                <div>
                  <div className="relative aspect-[4/3] bg-gradient-to-b from-cream to-cream-warm/70 p-3 flex items-center justify-center overflow-hidden">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full h-full object-contain filter drop-shadow group-hover:scale-105 transition-transform"
                      loading="lazy"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src = '/assets/food/classic_fries.png';
                      }}
                    />
                    
                    {product.badge && (
                      <span className="absolute top-3 left-3 bg-burgundy text-white text-[10px] font-extrabold px-2.5 py-0.5 rounded-full shadow-sm">
                        {product.badge}
                      </span>
                    )}

                    <span className="absolute bottom-2 right-3 text-[10px] font-bold text-espresso/60 uppercase">
                      {product.portion}
                    </span>
                  </div>

                  <div className="p-4 space-y-2">
                    <div className="flex items-center justify-between gap-1">
                      <h3 className="font-display font-black text-lg text-burgundy leading-snug">
                        {product.name}
                      </h3>
                      <span className="text-[10px] font-bold uppercase tracking-wider text-caramel-warm">
                        {product.category}
                      </span>
                    </div>

                    <p className="text-xs text-espresso/70 line-clamp-2 leading-relaxed">
                      {product.description}
                    </p>

                    {product.ingredients && (
                      <div className="flex flex-wrap gap-1 pt-1">
                        {product.ingredients.slice(0, 3).map((ing, i) => (
                          <span key={i} className="text-[9.5px] bg-cream-warm/80 text-espresso/70 px-1.5 py-0.5 rounded">
                            {ing}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="p-4 pt-0 flex items-center justify-between border-t border-amber-50 mt-2">
                  <div>
                    {isConfirmedPrice ? (
                      <span className="text-xl font-black text-burgundy">₹{product.price}</span>
                    ) : (
                      <div className="flex items-center gap-1 text-[11px] font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded-md">
                        <HelpCircle className="w-3 h-3 text-amber-700" />
                        <span>Price to be confirmed</span>
                      </div>
                    )}
                  </div>

                  <button
                    onClick={() => onAddProduct(product)}
                    className="inline-flex items-center gap-1 bg-burgundy hover:bg-terracotta active:scale-95 text-white px-3.5 py-2 rounded-xl font-bold text-xs transition-colors shadow-sm"
                    aria-label={`Add ${product.name} to order`}
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Add</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
};
