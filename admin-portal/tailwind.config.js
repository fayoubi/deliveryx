/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // UberEats-inspired color palette
        primary: {
          50: '#e6f9f0',
          100: '#b3eed4',
          200: '#80e3b8',
          300: '#4dd89c',
          400: '#1acd80',
          500: '#06C167', // Main UberEats green
          600: '#05a857',
          700: '#048f47',
          800: '#037637',
          900: '#025d27',
        },
        secondary: {
          50: '#f5f5f5',
          100: '#e0e0e0',
          200: '#bdbdbd',
          300: '#9e9e9e',
          400: '#757575',
          500: '#545454',
          600: '#3d3d3d',
          700: '#2b2b2b',
          800: '#1a1a1a',
          900: '#000000',
        },
        danger: {
          50: '#fee',
          100: '#fcc',
          200: '#f99',
          300: '#f66',
          400: '#f33',
          500: '#DC2626', // Red for delete actions
          600: '#c32020',
          700: '#aa1a1a',
          800: '#911515',
          900: '#780f0f',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0, 0, 0, 0.08)',
        'card-hover': '0 4px 12px rgba(0, 0, 0, 0.12)',
        'modal': '0 8px 32px rgba(0, 0, 0, 0.24)',
      },
      borderRadius: {
        'xl': '0.75rem',
        '2xl': '1rem',
      },
    },
  },
  plugins: [],
}
