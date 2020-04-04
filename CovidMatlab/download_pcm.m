function download_pcm()
%% Crea cartella temporanea dove scaricare i file
mkdir temp

%% Scarica i file nella cartella temporanea e gli unzippa
url = 'https://github.com/pcm-dpc/COVID-19/archive/master.zip';
filename = 'temp/master.zip';
file_download = websave(filename,url);
unzip(file_download, 'temp');
delete(filename)


% Delete old data
data_folder = 'data/italia/dati-regioni';
if ~exist(data_folder, 'dir')
    mkdir(data_folder)
end
rmdir(data_folder,'s')

% Copy necessary data
movefile("temp/COVID-19-master/dati-regioni","data/italia/dati-regioni");

% Rimuove la cartella temporanea
rmdir('temp','s')
end