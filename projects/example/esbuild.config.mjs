import * as esbuild from 'esbuild';

const isWatch = process.argv.includes('--watch');

const buildOptions = {
  entryPoints: ['src/Code.ts'],
  bundle: false,  // 번들링 없이 단순 컴파일만
  outfile: 'dist/Code.js',
  platform: 'neutral',
  target: 'es2020',
  banner: {
    js: '// Auto-generated from TypeScript - Edit src/Code.ts instead\n'
  }
};

if (isWatch) {
  const context = await esbuild.context(buildOptions);
  await context.watch();
  console.log('👀 Watching for changes...');
} else {
  await esbuild.build(buildOptions);
  console.log('✅ Build complete');
}
