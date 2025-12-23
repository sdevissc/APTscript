# APTscript

This is a simple script that 

a) platesolve a fits file using ASTAP
b) produces a tsv file (vizierdb.txt) with all sources from Vizier around the RA-DEC coordinates of the image
c) produces a tsv file (sourcesimage.txt) using Aperture PhotoMetry Tool with all sources within the image

usage: ./script.sh config.cfg

Several things must be installed:
1) astropy (to read fits header)
2) ASTAP
3) vizquery (to do command line queries to CDS/Vizier)
4) Aperture Photometry Tool

The config.cfg file contains the necessary information for the script to be run:

## fichier de configuration contenant
1) Nom de l'objet (crée un repo du même nom pour y déposer les tsv)
2) l'adresse du fits a traiter
3) l'adresse du repo dans lequel le repo ayant le nom mentionné en 1) est créé
3) l'adresse du repo de travail de APT
5) l'adresse du soft vizquery

name=CometName
fitsadd=/home/johndoe/this_image.fit
wdir=/home/johndoe/WDir/
APThDir=/home/johndoe/.AperturePhotometryTool
vqadd=/home/johndoe/Programs/cdsclient/cdsclient-4.07/vizquer


