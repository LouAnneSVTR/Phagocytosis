//Variables globales
Environnement e;
int nbAgent;

//***********************************************************************************
public void settings() {
    fullScreen();
}

//***********************************************************************************
public void setup() {

    background(0);

    //Initialisations des variables globales
    nbAgent = ( (height+width)/2 * 50) / 100; //On donne le nombre d'agent en fontion de la taille de l'écran.
    e = new Environnement(nbAgent);

    //Initialisation des nbAgent.
    e.intitAgent();
}

//***********************************************************************************
public void draw() {

    background(0);
    e.drawEnvironnement();
    e.updateAllAgent();
}

//***********************************************************************************
public void mouseClicked(){
    e.newAgent();
}
