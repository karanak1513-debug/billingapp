import React, { useState } from 'react';
import { Eye, X, ZoomIn } from 'lucide-react';

interface PosterItem {
  id: string;
  title: string;
  tagline: string;
  badge: string;
  image: string;
}

export const PosterShowcase: React.FC = () => {
  const [selectedPoster, setSelectedPoster] = useState<PosterItem | null>(null);

  const posters: PosterItem[] = [
    {
      id: 'combos',
      title: 'Combo Menu Poster',
      tagline: 'Crispy Bites • Chilled Sips • Great Vibes',
      badge: 'Official Combo Artwork',
      image: '/assets/posters/combos_poster.jpg',
    },
    {
      id: 'snacks',
      title: 'Our Snacks Poster',
      tagline: 'Crispy Bites • Tasty Treats • Good Vibes',
      badge: 'Handcrafted Food Artwork',
      image: '/assets/posters/snacks_poster.jpg',
    },
    {
      id: 'drinks',
      title: 'Our Drinks Poster',
      tagline: 'Cool Sips Happy Mood • Same Great Vibes',
      badge: 'Chill O’Clock Sips Artwork',
      image: '/assets/posters/drinks_poster.jpg',
    },
  ];

  return (
    <section id="posters" className="py-20 bg-burgundy text-white relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center max-w-2xl mx-auto mb-14">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 border border-caramel/40 text-caramel text-xs font-bold uppercase tracking-wider mb-3">
            <Eye className="w-3.5 h-3.5 text-golden" />
            <span>Visual Origin & Branding</span>
          </div>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-black text-cream tracking-tight">
            Original Stall Wall Posters
          </h2>
          <p className="mt-3 text-base text-cream/80">
            Every product card, color code, and font in this app was drawn directly from our authentic printed festival stall menu posters.
          </p>
        </div>

        {/* 3 Posters Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 items-start">
          {posters.map((poster) => (
            <div
              key={poster.id}
              onClick={() => setSelectedPoster(poster)}
              className="group cursor-pointer rounded-3xl bg-burgundy-dark border-2 border-caramel/40 overflow-hidden shadow-2xl hover:border-golden transition-all duration-300 transform hover:-translate-y-1.5"
            >
              <div className="relative aspect-[2/3] overflow-hidden bg-burgundy/50">
                <img
                  src={poster.image}
                  alt={poster.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                  loading="lazy"
                />

                <div className="absolute inset-0 bg-gradient-to-t from-burgundy-dark via-transparent to-transparent opacity-80"></div>

                <div className="absolute top-3 left-3 bg-golden text-burgundy-dark font-black text-[11px] px-2.5 py-1 rounded-full uppercase shadow">
                  {poster.badge}
                </div>

                <div className="absolute bottom-4 left-4 right-4 flex items-center justify-between">
                  <div>
                    <h3 className="font-display font-bold text-lg text-cream">{poster.title}</h3>
                    <p className="text-xs text-caramel-fixed">{poster.tagline}</p>
                  </div>
                  <div className="p-2 rounded-full bg-white/20 text-white backdrop-blur group-hover:bg-golden group-hover:text-burgundy transition-colors">
                    <ZoomIn className="w-4 h-4" />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

      </div>

      {/* Poster Zoom Modal */}
      {selectedPoster && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="relative max-w-2xl w-full max-h-[90vh] flex flex-col items-center">
            <button
              onClick={() => setSelectedPoster(null)}
              className="absolute -top-12 right-0 p-2 text-white/80 hover:text-white bg-white/10 rounded-full transition-colors"
              aria-label="Close modal"
            >
              <X className="w-6 h-6" />
            </button>
            <img
              src={selectedPoster.image}
              alt={selectedPoster.title}
              className="max-h-[80vh] w-auto rounded-2xl shadow-2xl border-2 border-caramel/50 object-contain"
            />
            <div className="mt-3 text-center">
              <p className="text-sm font-bold text-cream">{selectedPoster.title}</p>
              <p className="text-xs text-caramel">{selectedPoster.tagline}</p>
            </div>
          </div>
        </div>
      )}
    </section>
  );
};
