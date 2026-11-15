import {mkdir,readFile,writeFile} from 'node:fs/promises';
await mkdir('public',{recursive:true});
for(const file of ['resort.jpg','icon-192.png','icon-512.png'])await writeFile('public/'+file,Buffer.from(await readFile('assets/'+file+'.b64','utf8'),'base64'));
