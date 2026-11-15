import {cp,mkdir,readFile,writeFile} from 'node:fs/promises';
await mkdir('dist',{recursive:true});
await cp('site','dist',{recursive:true});
await cp('public','dist',{recursive:true});
for(const file of ['resort.jpg','icon-192.png','icon-512.png'])await writeFile('dist/'+file,Buffer.from(await readFile('assets/'+file+'.b64','utf8'),'base64'));
