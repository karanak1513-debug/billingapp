import React, { useState } from 'react';
import { ShoppingBag, Menu as MenuIcon, X, Sparkles, Utensils, GlassWater } from 'lucide-react';

interface NavbarProps {
  cartCount: number;
  onOpenCart: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ cartCount, onOpenCart }) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 bg-burgundy/95 backdrop-blur-md border-b border-caramel/30 text-white transition-all shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          
          {/* Logo & Brand Identity */}
          <a href="#" className="flex items-center gap-3 group">
            <div className="relative">
              <img 
                src="/assets/branding/logo.png" 
                alt="Snacks O'Clock Logo" 
                className="w-12 h-12 rounded-full border-2 border-caramel object-cover shadow-sm group-hover:scale-105 transition-transform"
                onError={(e) => {
                  (e.target as HTMLImageElement).src = '/assets/branding/favicon.png';
                }}
              />
              <span className="absolute -bottom-1 -right-1 flex h-3 w-3">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-golden opacity-75"></span>
                <span className="relative inline-flex rounded-full h-3 w-3 bg-golden"></span>
              </span>
            </div>
            
            <div className="flex flex-col">
              <div className="flex items-center gap-1.5 font-display font-extrabold text-lg sm:text-xl tracking-tight leading-none text-white">
                <span>Snacks O’Clock</span>
                <span className="text-caramel font-light">×</span>
                <span className="text-caramel">Chill O’Clock</span>
              </div>
              <span className="text-[11px] font-medium text-caramel-fixed tracking-wider uppercase mt-1">
                Crispy Bites • Chilled Sips • Great Vibes
              </span>
            </div>
          </a>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-8">
            <a href="#menu" className="text-sm font-semibold text-cream hover:text-golden transition-colors flex items-center gap-1.5">
              <Utensils className="w-4 h-4 text-caramel" />
              Menu
            </a>
            <a href="#combos" className="text-sm font-semibold text-cream hover:text-golden transition-colors flex items-center gap-1.5">
              <Sparkles className="w-4 h-4 text-golden" />
              Combo Deals
            </a>
            <a href="#posters" className="text-sm font-semibold text-cream hover:text-golden transition-colors flex items-center gap-1.5">
              <GlassWater className="w-4 h-4 text-caramel" />
              Wall Posters
            </a>
            <a href="#story" className="text-sm font-semibold text-cream hover:text-golden transition-colors">
              Our Story
            </a>
            <a href="#location" className="text-sm font-semibold text-cream hover:text-golden transition-colors">
              Stall & Timings
            </a>
          </nav>

          {/* Action CTA & Cart Basket Button */}
          <div className="flex items-center gap-3">
            <button
              onClick={onOpenCart}
              className="relative flex items-center gap-2 bg-gradient-to-r from-terracotta to-caramel-warm hover:brightness-110 active:scale-95 text-white px-4 py-2.5 rounded-full font-bold text-sm shadow-md transition-all border border-amber-300/30"
              aria-label="View Order Basket"
            >
              <ShoppingBag className="w-4 h-4" />
              <span className="hidden sm:inline">Order Basket</span>
              {cartCount > 0 && (
                <span className="flex items-center justify-center w-5 h-5 bg-white text-burgundy font-black text-xs rounded-full shadow">
                  {cartCount}
                </span>
              )}
            </button>

            {/* Mobile Hamburger Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 rounded-lg text-cream hover:text-white hover:bg-white/10 transition-colors"
              aria-label="Toggle mobile menu"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <MenuIcon className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Dropdown Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-burgundy-dark border-t border-caramel/20 px-4 pt-3 pb-6 space-y-3 animate-in slide-in-from-top-2">
          <a
            href="#menu"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-md font-semibold text-base text-cream hover:bg-white/10"
          >
            🍽️ Explore Menu
          </a>
          <a
            href="#combos"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-md font-semibold text-base text-golden hover:bg-white/10"
          >
            🔥 Value Combos
          </a>
          <a
            href="#posters"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-md font-semibold text-base text-cream hover:bg-white/10"
          >
            🖼️ Poster Gallery
          </a>
          <a
            href="#story"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-md font-semibold text-base text-cream hover:bg-white/10"
          >
            ❤️ Brand Story
          </a>
          <a
            href="#location"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-md font-semibold text-base text-cream hover:bg-white/10"
          >
            📍 Stall Location
          </a>
        </div>
      )}
    </header>
  );
};
