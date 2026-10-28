import { useState } from 'react';
import { Navbar } from './components/Navbar';
import { Hero } from './components/Hero';
import { CombosSection } from './components/CombosSection';
import { MenuSection } from './components/MenuSection';
import { PosterShowcase } from './components/PosterShowcase';
import { BrandStory } from './components/BrandStory';
import { Footer } from './components/Footer';
import { OrderEnquiryModal, CartEntry } from './components/OrderEnquiryModal';
import { Product, Combo } from './types';

export function App() {
  const [cart, setCart] = useState<CartEntry[]>([]);
  const [isCartOpen, setIsCartOpen] = useState(false);

  const handleAddProduct = (product: Product) => {
    // If product has confirmed price, add to cart
    if (product.price === null) {
      alert(`The price for "${product.name}" is pending stall confirmation. You can enquire directly at the counter!`);
      return;
    }

    const price = product.price;

    setCart((prev) => {
      const existing = prev.find((item) => item.id === product.id);
      if (existing) {
        return prev.map((item) =>
          item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [
        ...prev,
        {
          id: product.id,
          name: product.name,
          price: price,
          quantity: 1,
          type: 'product',
          image: product.image,
        },
      ];
    });
    setIsCartOpen(true);
  };

  const handleAddCombo = (combo: Combo) => {
    setCart((prev) => {
      const existing = prev.find((item) => item.id === combo.id);
      if (existing) {
        return prev.map((item) =>
          item.id === combo.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [
        ...prev,
        {
          id: combo.id,
          name: combo.name,
          price: combo.price,
          quantity: 1,
          type: 'combo',
          image: combo.image,
        },
      ];
    });
    setIsCartOpen(true);
  };

  const handleUpdateQuantity = (id: string, delta: number) => {
    setCart((prev) =>
      prev
        .map((item) => {
          if (item.id === id) {
            const newQty = item.quantity + delta;
            return newQty > 0 ? { ...item, quantity: newQty } : null;
          }
          return item;
        })
        .filter((x): x is CartEntry => x !== null)
    );
  };

  const handleRemoveItem = (id: string) => {
    setCart((prev) => prev.filter((item) => item.id !== id));
  };

  const handleClearCart = () => {
    setCart([]);
  };

  const totalCartCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <div className="min-h-screen flex flex-col bg-cream text-espresso selection:bg-caramel-fixed selection:text-burgundy">
      <Navbar
        cartCount={totalCartCount}
        onOpenCart={() => setIsCartOpen(true)}
      />

      <main className="flex-1">
        <Hero />
        <CombosSection onAddCombo={handleAddCombo} />
        <MenuSection
          onAddProduct={handleAddProduct}
          onAddCombo={handleAddCombo}
        />
        <PosterShowcase />
        <BrandStory />
      </main>

      <Footer />

      <OrderEnquiryModal
        isOpen={isCartOpen}
        onClose={() => setIsCartOpen(false)}
        cart={cart}
        onUpdateQuantity={handleUpdateQuantity}
        onRemoveItem={handleRemoveItem}
        onClearCart={handleClearCart}
      />
    </div>
  );
}

export default App;
