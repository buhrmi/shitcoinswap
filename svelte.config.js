import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'
import { importAssets } from 'svelte-preprocess-import-assets'
import { compile } from 'svelte/compiler'

export default {
  // Consult https://svelte.dev/docs#compile-time-svelte-preprocess
  // for more information about preprocessors
  preprocess: [
    vitePreprocess(),
    importAssets()
  ],
	compilerOptions: {
		experimental: {
			async: true
		}
	}
}
