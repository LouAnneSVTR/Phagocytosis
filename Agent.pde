public class Agent {
private PVector position;

//3 diametres pour faire "respirer" l'agent.
private float diameter, diameterOrigin, diameterFinal;

//Pour la respiration.
//Définit si l'agent doit diminuer ou augmenter.
//"true", le rayon augmente, "false, le rayon diminue.
private boolean change;

private int c1; //Représente la couleur d'un agent "élémentaire".
private int c2; //Représente avec "c1" les deux couleurs d'interpolation d'un agent "phagocyté".
private int alpha;

private boolean is_Phagocyte; //Pour savoir si l'agent est issu d'un phagocytose ou non.
private float life; //Pour l'interpolation, on se sert de la duree de vie.


//Constructeur 1 : Agent "élémentaire".
Agent( PVector p, float diameter) {
    this.position        = p;

    this.diameter        = diameter;
    this.diameterOrigin  = this.diameter;
    this.diameterFinal   = this.diameterOrigin + (this.diameterOrigin )/ 10; //On ajoute 10% du diametre Origin.
    this.change          = true; //Le rayon commence par augmenter.

    this.c1              = color( random(0,255),  random(0,255), random(0,255));
    this.alpha           = (int) random(255);

    this.is_Phagocyte    = false; //Car l'Agent est "élémentaire".

    this.life            = 0;
}


//Constructeur 2 : Agent "phagocyte".
Agent( PVector p, float diameter,int a_color, int b_color, int a_alpha, int b_alpha) {
    this.position        = p;

    this.diameter        = diameter;
    this.diameterOrigin  = this.diameter;
    this.diameterFinal   = this.diameterOrigin + (this.diameterOrigin * 10) / 100;
    this.change          = true; //Le rayon commence par augmenter.

    this.c1              = a_color;
    this.c2              = b_color;
    this.alpha           = (a_alpha + b_alpha )/2;

    this.is_Phagocyte    = true ;
    this.life            = 0;
}

//*************************************** ACCESSEURS ***************************************
public PVector getPosition() {
    return this.position;
}

public int getC1() {
    return c1;
}

public int getAlpha() {
    return alpha;
}

public float getDiameter() {
    return this.diameter;
}


//************************************** DRAW **************************************
/** ROLE : Dessine "this" en fonction de son constructeur.
 *
 * PRECONDITION : "this" doit être initialisé.
 *
 * @param indexAgent
 */
public void drawAgent(int indexAgent){
    noStroke();
    if ( ! is_Phagocyte){ //Test si l'Agent est "élémentaire".
        fill(c1, this.alpha);
    } else {
        fill(this.interpol2Couleurs((float) (this.life*indexAgent/500), c1, c2), this.alpha ); //Interpolation de couleur pour les Agent "phagocyte".
    }
    circle(this.position.x, this.position.y, this.diameter);
    this.life+=0.05; //Augmentation de la durée de vie
}


//************************************* RAPPROCHEMENT AGENT ************************************************
/** ROLE : Rapproche 2 agent en fonction de leur positon en x et y.
 * Le rapprocheement est calculé par un pourcentage faible pour pouvoir observer les mouvements.
 *
 * @param nearAgent : Représente l'agent le plus proche du "this". Ce dernier dois se rapprocher de "aProche".
 * @return PVector
 */
public void update(Agent nearAgent) {
    //Variable
    float positionX_aProche = nearAgent.getPosition().x; //Position en x de l'agent le plus proche.
    float positionY_aProche = nearAgent.getPosition().y; //Position en y de l'agent le plus proche.

    float posAToAX          = this.getPosition().x - positionX_aProche; //Calcul de l'écart en x entre "this" et son agent proche.
    float posAToAY          = this.getPosition().y - positionY_aProche; //Calcul de l'écart en y entre "this" et son agent proche.

    float coeffX            = (float) (posAToAX * 1.5/100); //Calcul 1% de la distance en x.
    float coeffY            = (float) (posAToAY * 1.5/100); //Calcul 1% de la distance en y.

    PVector rapprochement   = new PVector (coeffX, coeffY);

    this.getPosition().sub(rapprochement); //On soustrait la nouvelle position calcul pour rapprocher "this" de son agent le plus proche.
}


//*************************************** INTERPOLATION *********************************************
/** ROLE : Interpolation simple.
 *
 * @param x float : Variable entre 0 et 1, sert à fluidifier l'interpolation.
 * @param a float : Valeur "a" à inteporler.
 * @param b float : Valeur "b" à inteporler.
 *
 * @return float
 */
private float interpol(float x, float a, float b) {
    return (b - a) * x + a;
}

//--------------------------------------------
/** ROLE : Interpolation 2 couleurs.
 * Appelle interpolSimple pour red, green et blue.
 *
 * @param x  float : Variable entre 0 et 1, sert à fluidifier l'interpolation.
 * @param c1 float : Couleur "c1" à inteporler pour chaque valeurs rgb.
 * @param c2 float : Couleur "c2" à inteporler pour chaque valeurs rgb.
 *
 * @return float
 */
private int interpol2Couleurs(float x, int c1, int c2) {
    int r1 = (int) red(c1);
    int r2 = (int) red(c2);
    int r3 = (int) interpol(x, r1, r2);

    int g1 = (int) green(c1);
    int g2 = (int) green(c2);
    int g3 = (int) interpol(x, g1, g2);

    int b1 = (int) blue(c1);
    int b2 = (int) blue(c2);
    int b3 = (int) interpol(x, b1, b2);

    return color(r3, g3, b3);
}


//*************************************** change RADIUS *********************************************
/** ROLE : Permet la "respiration" des Agents.
 *  Alterne entre la diminution et l'augmentation du diametre. Entre le diametre d'Origin et le final.
 *
 *  PRECONDITION : "this" doit être initialisé.
 */
public void changeRadius(){
    //Calcul du coefficient de diminution entre les 2 diametres.
    float coeff = ((this.diameterFinal - this.diameterOrigin) * 2) / 100;

    if( !change) { //Test si le rayon n'a pas diminué.
        if (this.diameter > this.diameterOrigin) {
            this.diameter -= coeff;

        } else {
            change = true; //Pour une future augmentation.
        }
    }
    if ( change){ //Test si le rayon a déjà diminué.
        if (this.diameter < this.diameterFinal) {
            this.diameter += coeff;

        } else {
            change = false; //Pour une future diminution.
        }
    }

}

}
