const js = require("@eslint/js");

module.exports = [
  js.configs.recommended,

  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: "commonjs",
      globals: {
        console: "readonly",
        require: "readonly",
        module: "readonly",
        exports: "readonly",
        describe: "readonly",
        test: "readonly",
        expect: "readonly"
      }
    },
    rules: {
      "no-console": "off",
      "no-unused-vars": "error",
      "semi": ["error", "always"],
      "quotes": ["error", "double"]
    }
  }
];