function downloadDataProtCiv()
%% crea cartella temporanea dove scaricare i file
mkdir ./temp

%% scarica i file nella cartella temporanea e gli unzippa
url = 'https://github.com/pcm-dpc/COVID-19/archive/master.zip';
filename = 'master.zip';
fileDownload = websave(filename,url);
unzip(fileDownload, 'temp');
delete master.zip

%delete old data
rmdir('data\italia\dati-regioni','s')

% copy necessary data
movefile(".\temp\COVID-19-master\dati-regioni",".\data\italia\dati-regioni");

% rimuove la cartella temporanea
rmdir([pwd '/temp'],'s')  
end