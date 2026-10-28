import React from 'react';
import { Sparkles, ArrowRight, Utensils, GlassWater, Clock, Flame } from 'lucide-react';

export const Hero: React.FC = () => {
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-burgundy via-burgundy-dark to-[#20050B] text-white pt-10 pb-20 lg:pt-16 lg:pb-28">
      {/* Background Decorative Rings & Glows */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-full pointer-events-none overflow-hidden opacity-30">
        <div className="absolute -top-32 -left-32 w-96 h-96 bg-golden/20 rounded-full blur-3xl"></div>
        <div className="absolute top-1/2 -right-32 w-96 h-96 bg-terracotta/30 rounded-full blur-3xl"></div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Left Column: Headlines & Call-to-actions */}
          <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
            
            {/* Pill Badge */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/10 border border-caramel/40 text-xs sm:text-sm font-bold text-caramel-fixed tracking-wide shadow-inner">
              <span className="flex h-2 w-2 rounded-full bg-golden animate-pulse"></span>
              <span>Crispy Bites • Chilled Sips • Festival Favorites</span>
            </div>

            {/* Main Headline */}
            <h1 className="text-4xl sm:text-5xl md:text-6xl font-display font-black tracking-tight leading-[1.1] text-cream">
              Good Food. <br />
              <span className="bg-gradient-to-r from-golden via-amber-200 to-caramel bg-clip-text text-transparent">
                Chilled Drinks.
              </span> <br />
              Great Vibes.
            </h1>

            {/* Subheading / Description */}
            <p className="text-base sm:text-lg text-cream/90 max-w-xl mx-auto lg:mx-0 font-normal leading-relaxed">
              Welcome to <span className="text-golden font-bold">Snacks O’Clock × Chill O’Clock</span> — your go-to destination for mouthwatering loaded fries, crunchy hot spring rolls, and ice-cold artisan mocktails. Handcrafted fresh at our stall, loved across campuses.
            </p>

            {/* Feature Highlights Pills */}
            <div className="flex flex-wrap justify-center lg:justify-start gap-3 pt-2">
              <div className="flex items-center gap-2 bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-xs font-semibold text-cream">
                <Flame className="w-3.5 h-3.5 text-golden" />
                <span>Made Fresh To Order</span>
              </div>
              <div className="flex items-center gap-2 bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-xs font-semibold text-cream">
                <GlassWater className="w-3.5 h-3.5 text-blue-300" />
                <span>5 Signature Mocktails</span>
              </div>
              <div className="flex items-center gap-2 bg-white/5 border border-white/10 px-3 py-1.5 rounded-lg text-xs font-semibold text-cream">
                <Clock className="w-3.5 h-3.5 text-caramel" />
                <span>Quick Counter Service</span>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-4">
              <a
                href="#menu"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-7 py-3.5 rounded-full bg-golden text-burgundy-dark font-extrabold text-base shadow-lg hover:bg-amber-300 active:scale-95 transition-all"
              >
                <Utensils className="w-5 h-5 text-burgundy" />
                <span>Explore Menu</span>
                <ArrowRight className="w-4 h-4 ml-0.5" />
              </a>

              <a
                href="#combos"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-7 py-3.5 rounded-full bg-burgundy-surface/80 hover:bg-burgundy-surface text-cream border border-caramel/40 font-bold text-base shadow transition-all active:scale-95"
              >
                <Sparkles className="w-5 h-5 text-golden" />
                <span>View Combos (Save ₹10)</span>
              </a>
            </div>

          </div>

          {/* Right Column: Visual Composition with Food Photography */}
          <div className="lg:col-span-5 relative flex justify-center">
            
            {/* Visual Frame */}
            <div className="relative w-full max-w-md sm:max-w-lg aspect-square">
              
              {/* Outer decorative halo */}
              <div className="absolute inset-0 rounded-3xl bg-gradient-to-tr from-caramel/20 via-golden/10 to-transparent border-2 border-caramel/30 rotate-2"></div>
              
              {/* Main Card with Collage */}
              <div className="relative w-full h-full rounded-3xl bg-burgundy/80 backdrop-blur-md border border-caramel/40 p-4 sm:p-6 overflow-hidden shadow-2xl flex flex-col justify-between">
                
                {/* Card Header Tag */}
                <div className="flex items-center justify-between z-10">
                  <span className="bg-golden text-burgundy font-black text-xs uppercase px-3 py-1 rounded-full shadow">
                    Combo Highlight
                  </span>
                  <span className="text-xs font-bold text-caramel tracking-wider uppercase">
                    Classic Fries + Drink
                  </span>
                </div>

                {/* Hero Center Imagery */}
                <div className="relative my-auto flex items-center justify-center">
                  <img
                    src="/assets/combos/classic_combo.png"
                    alt="Classic Fries and Chilled Drink Combo"
                    className="w-4/5 object-contain filter drop-shadow-[0_15px_25px_rgba(0,0,0,0.6)] hover:scale-105 transition-transform duration-300"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/food/classic_fries.png';
                    }}
                  />
                  
                  {/* Floating Price Pill */}
                  <div className="absolute -bottom-2 right-4 bg-gradient-to-r from-terracotta to-amber-600 text-white px-4 py-2 rounded-2xl shadow-xl border border-white/20 transform rotate-[-3deg]">
                    <div className="text-[10px] font-semibold text-amber-200 uppercase">Combo Deal</div>
                    <div className="text-lg font-black leading-none">Only ₹110</div>
                  </div>
                </div>

                {/* Card Bottom Badges */}
                <div className="grid grid-cols-2 gap-2 text-center text-xs pt-4 border-t border-white/10 z-10">
                  <div className="bg-white/5 py-2 px-3 rounded-xl border border-white/5">
                    <p className="text-golden font-bold">Loaded Cheese</p>
                    <p className="text-[11px] text-cream/70">Cheddar & Spices</p>
                  </div>
                  <div className="bg-white/5 py-2 px-3 rounded-xl border border-white/5">
                    <p className="text-blue-300 font-bold">Blue Lagoon</p>
                    <p className="text-[11px] text-cream/70">Zesty Citrus Fizz</p>
                  </div>
                </div>

              </div>

            </div>

          </div>

        </div>
      </div>
    </section>
  );
};
