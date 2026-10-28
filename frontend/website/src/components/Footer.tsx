import React from 'react';
import { Heart, MapPin, Clock, ShieldCheck } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer id="location" className="bg-[#1C060C] text-cream border-t border-caramel/20 pt-16 pb-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 pb-12 border-b border-white/10">
          
          {/* Brand Col */}
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <img
                src="/assets/branding/logo.png"
                alt="Snacks O'Clock Logo"
                className="w-10 h-10 rounded-full border border-caramel object-cover"
                onError={(e) => {
                  (e.target as HTMLImageElement).src = '/assets/branding/favicon.png';
                }}
              />
              <div className="font-display font-black text-lg text-cream">
                Snacks O’Clock <span className="text-caramel font-light">×</span> Chill O’Clock
              </div>
            </div>
            <p className="text-xs text-cream/70 leading-relaxed">
              Handcrafted crispy fries, loaded cheese bowls, golden spring rolls, and ice-cold mocktail thirst-quenchers. Fresh bites, fast counter billing.
            </p>
            <div className="flex items-center gap-2 text-xs text-caramel-fixed">
              <ShieldCheck className="w-4 h-4 text-golden" />
              <span>FSSAI Lic. No: 21524098000412</span>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-3">
            <h4 className="font-display font-bold text-sm text-golden uppercase tracking-wider">
              Quick Navigation
            </h4>
            <ul className="space-y-2 text-xs text-cream/80">
              <li>
                <a href="#menu" className="hover:text-golden transition-colors">Full Food & Drinks Menu</a>
              </li>
              <li>
                <a href="#combos" className="hover:text-golden transition-colors">Value Combos (Save ₹10)</a>
              </li>
              <li>
                <a href="#posters" className="hover:text-golden transition-colors">Wall Posters & Artwork</a>
              </li>
              <li>
                <a href="#story" className="hover:text-golden transition-colors">Brand Story & Ingredients</a>
              </li>
            </ul>
          </div>

          {/* Stall Hours & Service */}
          <div className="space-y-3">
            <h4 className="font-display font-bold text-sm text-golden uppercase tracking-wider">
              Service Hours
            </h4>
            <div className="space-y-2 text-xs text-cream/80">
              <div className="flex items-start gap-2">
                <Clock className="w-4 h-4 text-caramel shrink-0 mt-0.5" />
                <div>
                  <p className="font-semibold text-white">Daily Counter Service</p>
                  <p className="text-[11px] text-cream/60">11:00 AM – 10:30 PM</p>
                </div>
              </div>
              <p className="text-[11px] text-emerald-400 font-semibold pt-1">
                • Active Shift / Live Counter Open
              </p>
            </div>
          </div>

          {/* Location & Payment */}
          <div className="space-y-3">
            <h4 className="font-display font-bold text-sm text-golden uppercase tracking-wider">
              Payment & Counter
            </h4>
            <div className="space-y-2 text-xs text-cream/80">
              <div className="flex items-start gap-2">
                <MapPin className="w-4 h-4 text-caramel shrink-0 mt-0.5" />
                <p>Campus Food Court / Main Stall Counter</p>
              </div>
              <p className="text-xs text-cream/60">
                Payment accepted: Cash, PhonePe, Google Pay, Paytm, & all UPI apps.
              </p>
            </div>
          </div>

        </div>

        {/* Bottom Bar */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-cream/60 gap-4">
          <p>© {new Date().getFullYear()} Snacks O’Clock × Chill O’Clock. All rights reserved.</p>
          <div className="flex items-center gap-1.5 text-caramel-fixed">
            <span>Made with</span>
            <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500" />
            <span>for food lovers and festival goers</span>
          </div>
        </div>

      </div>
    </footer>
  );
};
