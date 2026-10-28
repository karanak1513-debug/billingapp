import React, { useState } from 'react';
import { X, Trash2, Send, Copy, Check, ShoppingBag, Clock } from 'lucide-react';

export interface CartEntry {
  id: string;
  name: string;
  price: number;
  quantity: number;
  type: 'product' | 'combo';
  image: string;
}

interface OrderEnquiryModalProps {
  isOpen: boolean;
  onClose: () => void;
  cart: CartEntry[];
  onUpdateQuantity: (id: string, delta: number) => void;
  onRemoveItem: (id: string) => void;
  onClearCart: () => void;
}

export const OrderEnquiryModal: React.FC<OrderEnquiryModalProps> = ({
  isOpen,
  onClose,
  cart,
  onUpdateQuantity,
  onRemoveItem,
  onClearCart,
}) => {
  const [customerName, setCustomerName] = useState('');
  const [copied, setCopied] = useState(false);
  const [pickupNote, setPickupNote] = useState('Counter Pickup ASAP');

  if (!isOpen) return null;

  const totalAmount = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const generateOrderText = () => {
    let text = `🍟 *Order Enquiry — Snacks O’Clock × Chill O’Clock*\n`;
    if (customerName.trim()) text += `Customer: ${customerName.trim()}\n`;
    text += `Pickup: ${pickupNote}\n`;
    text += `--------------------------------\n`;
    cart.forEach((item) => {
      text += `• ${item.quantity}x ${item.name} — ₹${item.price * item.quantity}\n`;
    });
    text += `--------------------------------\n`;
    text += `*Estimated Total: ₹${totalAmount}*\n\n`;
    text += `Please let me know when this will be ready at the counter!`;
    return text;
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(generateOrderText());
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  const handleWhatsApp = () => {
    const text = encodeURIComponent(generateOrderText());
    // Direct WhatsApp enquiry
    window.open(`https://wa.me/?text=${text}`, '_blank');
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="relative w-full max-w-lg bg-white rounded-3xl shadow-2xl overflow-hidden border-2 border-caramel/40 max-h-[90vh] flex flex-col">
        
        {/* Header */}
        <div className="bg-burgundy text-white p-5 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-xl bg-white/10 text-golden">
              <ShoppingBag className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-display font-extrabold text-lg text-cream">Order Enquiry Basket</h3>
              <p className="text-xs text-caramel-fixed">Snacks O’Clock Counter Pickup</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-white/10 text-cream/80 hover:text-white transition-colors"
            aria-label="Close"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Cart Item List */}
        <div className="p-5 overflow-y-auto space-y-4 flex-1">
          {cart.length === 0 ? (
            <div className="text-center py-10 space-y-3">
              <div className="w-14 h-14 bg-cream-warm rounded-full flex items-center justify-center mx-auto text-espresso/40">
                <ShoppingBag className="w-7 h-7" />
              </div>
              <p className="font-bold text-espresso text-sm">Your order basket is empty</p>
              <p className="text-xs text-espresso/60 max-w-xs mx-auto">
                Explore our crispy snacks and signature mocktails to add items to your counter order!
              </p>
            </div>
          ) : (
            <>
              {cart.map((item) => (
                <div
                  key={item.id}
                  className="flex items-center justify-between p-3 rounded-2xl bg-cream/70 border border-caramel/20 gap-3"
                >
                  <img
                    src={item.image}
                    alt={item.name}
                    className="w-12 h-12 object-contain rounded-lg bg-white p-1 border border-caramel/20 shrink-0"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/food/classic_fries.png';
                    }}
                  />

                  <div className="flex-1 min-w-0">
                    <h4 className="font-bold text-sm text-burgundy truncate">{item.name}</h4>
                    <p className="text-xs text-espresso/70">
                      ₹{item.price} each • <span className="font-semibold text-burgundy">₹{item.price * item.quantity}</span>
                    </p>
                  </div>

                  {/* Quantity Stepper */}
                  <div className="flex items-center gap-2 bg-white px-2 py-1 rounded-xl border border-caramel/30 shrink-0">
                    <button
                      onClick={() => onUpdateQuantity(item.id, -1)}
                      className="w-6 h-6 flex items-center justify-center text-espresso/80 hover:text-burgundy font-bold text-sm rounded hover:bg-cream"
                      aria-label="Decrease quantity"
                    >
                      -
                    </button>
                    <span className="text-xs font-black text-burgundy min-w-4 text-center">
                      {item.quantity}
                    </span>
                    <button
                      onClick={() => onUpdateQuantity(item.id, 1)}
                      className="w-6 h-6 flex items-center justify-center text-espresso/80 hover:text-burgundy font-bold text-sm rounded hover:bg-cream"
                      aria-label="Increase quantity"
                    >
                      +
                    </button>
                  </div>

                  <button
                    onClick={() => onRemoveItem(item.id)}
                    className="p-1.5 text-espresso/40 hover:text-rose-600 transition-colors"
                    aria-label={`Remove ${item.name}`}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}

              {/* Customer Name & Timing inputs */}
              <div className="pt-3 space-y-3 border-t border-caramel/20">
                <div>
                  <label className="block text-[11px] font-bold text-espresso/80 uppercase tracking-wide mb-1">
                    Your Name (for order ticket)
                  </label>
                  <input
                    type="text"
                    placeholder="Enter your name..."
                    value={customerName}
                    onChange={(e) => setCustomerName(e.target.value)}
                    className="w-full px-3.5 py-2 text-xs rounded-xl border border-caramel/40 bg-cream/30 focus:outline-none focus:ring-2 focus:ring-burgundy text-espresso"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-bold text-espresso/80 uppercase tracking-wide mb-1">
                    Pickup Preference
                  </label>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <button
                      type="button"
                      onClick={() => setPickupNote('Counter Pickup ASAP')}
                      className={`p-2 rounded-xl font-bold border text-left transition-all ${
                        pickupNote === 'Counter Pickup ASAP'
                          ? 'border-burgundy bg-burgundy/10 text-burgundy'
                          : 'border-caramel/30 bg-white text-espresso/70'
                      }`}
                    >
                      <Clock className="w-3.5 h-3.5 inline mr-1 text-terracotta" />
                      Ready ASAP (5-7 mins)
                    </button>
                    <button
                      type="button"
                      onClick={() => setPickupNote('Pickup in 15-20 mins')}
                      className={`p-2 rounded-xl font-bold border text-left transition-all ${
                        pickupNote === 'Pickup in 15-20 mins'
                          ? 'border-burgundy bg-burgundy/10 text-burgundy'
                          : 'border-caramel/30 bg-white text-espresso/70'
                      }`}
                    >
                      <Clock className="w-3.5 h-3.5 inline mr-1 text-terracotta" />
                      In 15-20 Mins
                    </button>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>

        {/* Footer Actions */}
        {cart.length > 0 && (
          <div className="p-5 bg-warm-cream/50 border-t border-caramel/20 space-y-3">
            <div className="flex items-baseline justify-between">
              <span className="text-xs font-bold text-espresso/70 uppercase">Estimated Total</span>
              <span className="text-2xl font-black text-burgundy">₹{totalAmount}</span>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={handleCopy}
                className="flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl border border-caramel/40 font-bold text-xs text-burgundy bg-white hover:bg-cream transition-colors shadow-sm"
              >
                {copied ? <Check className="w-4 h-4 text-emerald-600" /> : <Copy className="w-4 h-4" />}
                <span>{copied ? 'Copied!' : 'Copy Summary'}</span>
              </button>

              <button
                onClick={handleWhatsApp}
                className="flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl bg-emerald-700 hover:bg-emerald-800 active:scale-95 text-white font-bold text-xs transition-colors shadow-md"
              >
                <Send className="w-4 h-4" />
                <span>Send to Counter</span>
              </button>
            </div>

            <div className="text-center">
              <button
                onClick={onClearCart}
                className="text-[11px] font-semibold text-espresso/50 hover:text-rose-600 transition-colors"
              >
                Clear all items
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};
