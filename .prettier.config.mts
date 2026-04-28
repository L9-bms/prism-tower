import { type Config } from "prettier";

const config: Config = {
  plugins: [
    "prettier-plugin-astro",
    "prettier-plugin-tailwindcss", // needs to be last
  ],
  overrides: [
    {
      files: "*.astro",
      options: {
        parser: "astro",
      },
    },
  ],
};

export default config;
