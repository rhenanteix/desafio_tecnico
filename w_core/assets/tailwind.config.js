module.exports = {
    content: [
      "../lib/**/*.{heex,ex,exs}",
      "./js/**/*.js"
    ],
    safelist: [
      "bg-green-100",
      "border-green-400",
      "bg-yellow-100",
      "border-yellow-400",
      "bg-red-200",
      "border-red-500",
      "animate-pulse"
    ],
    theme: {
      extend: {},
    },
    plugins: [],
  }