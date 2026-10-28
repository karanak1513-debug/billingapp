/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        burgundy: {
          DEFAULT: '#40121D',
          dark: '#2D0B13',
          surface: '#5B202C',
        },
        cream: {
          DEFAULT: '#FFF7ED',
          warm: '#F5E7D7',
          card: '#FFFFFF',
          container: '#FFE9E8',
        },
        caramel: {
          DEFAULT: '#D9A66E',
          warm: '#D97706',
          fixed: '#FFDBCE',
        },
        golden: '#FFC83D',
        terracotta: '#974723',
        espresso: '#2C1720',
      },
      fontFamily: {
        display: ['Epilogue', 'sans-serif'],
        sans: ['Manrope', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        'warm': '0 10px 25px -5px rgba(64, 18, 29, 0.12), 0 8px 10px -6px rgba(64, 18, 29, 0.08)',
        'warm-lg': '0 20px 35px -10px rgba(64, 18, 29, 0.18), 0 10px 15px -8px rgba(64, 18, 29, 0.10)',
      }
    },
  },
  plugins: [],
}
