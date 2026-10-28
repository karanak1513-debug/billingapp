import React from 'react';
import { Heart, Sparkles, Check, Flame, Trophy } from 'lucide-react';

export const BrandStory: React.FC = () => {
  return (
    <section id="story" className="py-20 bg-warm-cream/30 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Visual Story Frame */}
          <div className="lg:col-span-5 relative">
            <div className="relative mx-auto max-w-md aspect-[4/5] rounded-3xl overflow-hidden border-2 border-caramel/40 shadow-warm-lg bg-burgundy">
              <img
                src="/assets/posters/snacks_poster.jpg"
                alt="Snacks O'Clock Stall Identity"
                className="w-full h-full object-cover opacity-90"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-burgundy via-burgundy/40 to-transparent"></div>

              <div className="absolute bottom-6 left-6 right-6 text-white space-y-2">
                <span className="bg-golden text-burgundy-dark font-black text-xs uppercase px-3 py-1 rounded-full shadow">
                  Festival & Stall Culture
                </span>
                <h3 className="font-display font-black text-2xl leading-tight text-cream">
                  Snacks O’Clock × Chill O’Clock
                </h3>
                <p className="text-xs text-caramel-fixed">
                  Born from the buzz of college food festivals, designed to serve fast, fresh, and unforgettable flavors.
                </p>
              </div>
            </div>
          </div>

          {/* Right Column: Story Narrative */}
          <div className="lg:col-span-7 space-y-6">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-caramel/20 border border-caramel/40 text-burgundy text-xs font-bold uppercase tracking-wider">
              <Heart className="w-3.5 h-3.5 text-terracotta" />
              <span>Behind The Counter</span>
            </div>

            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-burgundy tracking-tight leading-tight">
              Small Bites. Big Smiles. <br />
              <span className="text-terracotta">Crafted for Pure Joy.</span>
            </h2>

            <p className="text-base text-espresso/80 leading-relaxed">
              <strong>Snacks O’Clock × Chill O’Clock</strong> was created around a simple culinary philosophy: good times begin with hot, crispy snacks and ice-cold artisan drinks. Whether you are craving golden French fries tossed in fiery Peri Peri spice or a soothing Blue Lagoon cooler to recharge, we bring top-tier food stall hospitality right to your hands.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
              <div className="bg-white p-4 rounded-2xl border border-caramel/30 shadow-sm flex items-start gap-3">
                <div className="p-2 rounded-xl bg-amber-100 text-burgundy">
                  <Flame className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-display font-bold text-sm text-burgundy">Fresh Cut & Fried</h4>
                  <p className="text-xs text-espresso/70 mt-0.5">Cooked upon ordering for unbeatable crunch and zero sogginess.</p>
                </div>
              </div>

              <div className="bg-white p-4 rounded-2xl border border-caramel/30 shadow-sm flex items-start gap-3">
                <div className="p-2 rounded-xl bg-blue-100 text-blue-900">
                  <Sparkles className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-display font-bold text-sm text-burgundy">Real Citrus & Mint</h4>
                  <p className="text-xs text-espresso/70 mt-0.5">Signature mocktails prepared with crushed ice and fresh garnishes.</p>
                </div>
              </div>

              <div className="bg-white p-4 rounded-2xl border border-caramel/30 shadow-sm flex items-start gap-3">
                <div className="p-2 rounded-xl bg-emerald-100 text-emerald-900">
                  <Check className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-display font-bold text-sm text-burgundy">100% Vegetarian</h4>
                  <p className="text-xs text-espresso/70 mt-0.5">Dedicated vegetarian preparation with premium oil and hygienic standards.</p>
                </div>
              </div>

              <div className="bg-white p-4 rounded-2xl border border-caramel/30 shadow-sm flex items-start gap-3">
                <div className="p-2 rounded-xl bg-rose-100 text-rose-900">
                  <Trophy className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-display font-bold text-sm text-burgundy">Pocket-Friendly Combos</h4>
                  <p className="text-xs text-espresso/70 mt-0.5">Value meals engineered to give students and foodies maximum value.</p>
                </div>
              </div>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
};
