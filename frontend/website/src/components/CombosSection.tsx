import React from 'react';
import { COMBOS } from '../data/menu';
import { Combo } from '../types';
import { Sparkles, CheckCircle2, Plus, Percent } from 'lucide-react';

interface CombosSectionProps {
  onAddCombo: (combo: Combo) => void;
}

export const CombosSection: React.FC<CombosSectionProps> = ({ onAddCombo }) => {
  return (
    <section id="combos" className="py-20 bg-warm-cream/50 relative overflow-hidden">
      
      {/* Decorative Poster Ribbon */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header with Burgundy Brush style */}
        <div className="text-center max-w-2xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-terracotta/10 border border-terracotta/30 text-terracotta text-xs font-bold uppercase tracking-wider mb-4">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Combo Menu Special</span>
          </div>
          
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-burgundy tracking-tight">
            Crispy Bites + Chilled Sips
          </h2>
          
          <p className="mt-3 text-base sm:text-lg text-espresso/80">
            Inspired directly by our iconic stall poster. Pick your favorite crispy treat paired with any signature chilled drink and save on every bite!
          </p>
        </div>

        {/* 4 Combo Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
          {COMBOS.map((combo) => (
            <div
              key={combo.id}
              className="group bg-white rounded-3xl border-2 border-caramel/30 overflow-hidden shadow-warm hover:shadow-warm-lg hover:border-caramel transition-all duration-300 flex flex-col justify-between"
            >
              <div>
                {/* Image Composition Container */}
                <div className="relative aspect-[4/3] bg-gradient-to-b from-cream to-cream-warm/70 p-4 flex items-center justify-center overflow-hidden">
                  <img
                    src={combo.image}
                    alt={combo.name}
                    className="w-full h-full object-contain filter drop-shadow-md group-hover:scale-108 transition-transform duration-300"
                    loading="lazy"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/food/classic_fries.png';
                    }}
                  />

                  {/* Savings Tag */}
                  <div className="absolute top-3 right-3 bg-burgundy text-white text-xs font-black px-2.5 py-1 rounded-full flex items-center gap-1 shadow">
                    <Percent className="w-3 h-3 text-golden" />
                    <span>Save ₹{combo.savings}</span>
                  </div>

                  {/* Badge */}
                  {combo.badge && (
                    <div className="absolute bottom-3 left-3 bg-golden text-burgundy-dark text-[11px] font-extrabold px-2.5 py-0.5 rounded-full shadow-sm">
                      {combo.badge}
                    </div>
                  )}
                </div>

                {/* Combo Details */}
                <div className="p-5 sm:p-6 space-y-4">
                  <div>
                    <h3 className="font-display font-black text-xl text-burgundy group-hover:text-terracotta transition-colors">
                      {combo.name}
                    </h3>
                    <p className="text-xs text-espresso/70 mt-1 line-clamp-2 leading-relaxed">
                      {combo.description}
                    </p>
                  </div>

                  {/* Included Items Checklist */}
                  <div className="space-y-1.5 py-2 border-y border-amber-100/80">
                    <div className="text-[11px] font-bold text-caramel-warm uppercase tracking-wide">
                      What's Included:
                    </div>
                    {combo.includedItems.map((item, idx) => (
                      <div key={idx} className="flex items-start gap-1.5 text-xs text-espresso/90">
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0 mt-0.5" />
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Bottom Price & Add Action */}
              <div className="p-5 sm:p-6 pt-0 flex items-center justify-between">
                <div>
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-burgundy">₹{combo.price}</span>
                    <span className="text-sm font-semibold text-espresso/40 line-through">
                      ₹{combo.originalPrice}
                    </span>
                  </div>
                  <span className="text-[10px] font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-md">
                    Instant combo savings
                  </span>
                </div>

                <button
                  onClick={() => onAddCombo(combo)}
                  className="inline-flex items-center gap-1.5 bg-burgundy hover:bg-terracotta active:scale-95 text-white px-4 py-2.5 rounded-2xl font-bold text-xs shadow-md transition-all"
                  aria-label={`Add ${combo.name} to order`}
                >
                  <Plus className="w-4 h-4" />
                  <span>Add Combo</span>
                </button>
              </div>

            </div>
          ))}
        </div>

      </div>
    </section>
  );
};
