// script.js



/* relatifDir.js */
function relatifDir(chemin, dossier) {
    console.log("relatifDir", chemin, dossier)
    monDossier = dossier.replace(chemin, '')
    return monDossier
}
