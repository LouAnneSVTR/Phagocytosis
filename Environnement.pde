public class Environnement {

    private ArrayList<Agent> agentList;
    private int nbAgent;
    private int diameterAgent;
    private float limitPhagocytose;


    //Constructeur
    Environnement(int nbAgent) {
        this.nbAgent           = nbAgent;
        this.agentList         = new ArrayList<Agent>();

        this.limitPhagocytose  = 5;
    }

    //*************************************** ACCESSEURS ***************************************
    public ArrayList<Agent> getAgentList() {
        return  this.agentList;
    }


    //*************************************** INIT AGENT ***************************************
    /** ROLE : Initialise les nbAgent de l'Envirronnement.
     *  Empêche la création d'agent en dehors du cadre et la collision de 2 agents. */
    public void intitAgent() {
        for (int i = 0; i < this.nbAgent; i++) {

            //On donne un diametre random pour chaque agent.
            this.diameterAgent = (int) random(10,20);
            //On calcul 5% de ce diametre pour éviter que lors de leur "respiration", quand elle atteigne leur taille maximal, elle ne dépasse l'écran.
            int pourcentage = this.diameterAgent *5 /100;


            //Pour eviter la création d'agent a l'exterieur de l'écran.
            float posX = random(this.diameterAgent / 2 + pourcentage, width - this.diameterAgent / 2  + pourcentage);
            float posY = random(this.diameterAgent / 2  + pourcentage, height - this.diameterAgent / 2  + pourcentage);
            PVector pos = new PVector(posX, posY);

            //Tant que la position calculé est en en collision ab=vec celle d'un autre agent, on recommence le calcul.
            while (crashAgent(pos)) {

                //Pour eviter la création d'agent a l'exterieur de l'écran.
                 posX = random(this.diameterAgent / 2, width - this.diameterAgent / 2);
                 posY = random(this.diameterAgent / 2, height - this.diameterAgent / 2);
                 pos = new PVector(posX, posY);
            }
                Agent a = new Agent(pos, this.diameterAgent); //Création du nouvel agent.
                this.getAgentList().add(a); //Ajout dans la liste.
        }
    }

        //---------------------------------
        /** ROLE : Calcul si 2 agents sont dans le même secteur. Empeche que 2 agents se superposent.
         *
         * @return boolean */
        public boolean crashAgent(PVector pos){
            boolean result = false;

            for (int i = 0; i < this.getAgentList().size(); i++) {

                float agentInList_X = this.getAgentList().get(i).getPosition().x; //Récupération de la position en x de l'agent "i".
                float agentInList_Y = this.getAgentList().get(i).getPosition().y; //Récupération de la position en y de l'agent "i".

                //Calcul de la distance entre l'agent "i" et l'agent testé ( pos ).
                float distanceAgentToAgent =
                        sqrt(((pos.x - agentInList_X) * (pos.x - agentInList_X)) +
                                 (pos.y - agentInList_Y) * (pos.y - agentInList_Y));

                //Test si la distance calculé est inférieur au diameter de base donné dans environnement.
                if (distanceAgentToAgent <= (this.diameterAgent)) {
                    result = true;
                }
            }
            return result;
        }


    //*************************************** DRAW AGENT ***************************************
    /** ROLE : Dessine tous les agents de l'Envirronnement. 
     *  PRECONDITION : Tous les agents doivent être initialisés */
    public void drawEnvironnement () {
        for (int i = 0; i < this.getAgentList().size(); i++) {
            this.getAgentList().get(i).drawAgent(i);
            this.getAgentList().get(i).changeRadius();
        }
    }


    //************************************* NEAR AGENT ************************************************
     /** ROLE : Rend l'index de l'agent le plus proche.
     * Dans dans le cas ou il ne trouve pas d'agent à un écart inferieur à la taille de l'écran,
     * ( c'est a dire qu'il est seul), la fonction renvoie "-1"
     *
     * @param a : Représente l'agent auquel on cherche l'agent le plus proche.
     * @return int
     */
        public int searchNearAgent(Agent a) {
            //VARIABLE
            float distanceMin = height + width;
            int  indiceAgentProche = -1;

            //DEBUT
            for (int i = 0; i < this.getAgentList().size(); i++) {

                float aX = a.getPosition().x;
                float aY = a.getPosition().y;

                //Lisibilité : on initialise des variables prenant le position "X" et "Y" pour l'agent en parametre et l'agent "i" du for
                Agent agentInList = this.getAgentList().get(i);
                float agentInList_X = this.getAgentList().get(i).getPosition().x;
                float agentInList_Y = this.getAgentList().get(i).getPosition().y;

                //On calcul la distance entre les 2 agents avec la formule du Théorème de Pithagore
                float distanceAgentToAgent =
                        sqrt((aX - agentInList_X) * (aX - agentInList_X)  +
                                 (aY - agentInList_Y) * (aY - agentInList_Y) ) ;

                //On test si la nouvelle distance est plus petite que celle mémorisé
                //On test également si l'agent "agentInList" n'est pas l'agent "a" en paramètre de la fonction, pour éviter que la fonction ne renvoie notre paramètre
                //Dans le cas ou le "if" renvoie toujours faux, index retourne "a" signifiant une erreur.
                if (!(a.equals(agentInList)) && distanceAgentToAgent < distanceMin) {
                    distanceMin       = distanceAgentToAgent;
                    indiceAgentProche = i;
                }
            }
            return indiceAgentProche;
        }


    //************************************* UPDATE AGENT ************************************************
    /** ROLE :  Update la position de tous les agents de l'Environnement. 
     * PRECONDITION : Les agents doivent être initilisalisés. */
    public void updateAllAgent() {

        //On arrete l'update quand il ne reste qu'un seul agent.
        if ( this.getAgentList().size() > 1) {
            for (int i = 0; i < this.getAgentList().size(); i++) {

                int indexNearAgent = searchNearAgent(this.getAgentList().get(i)); //On recherche l'indice de l'agent le plus proche de "i".
                this.updateAgent(i,indexNearAgent); //Update de l'agente vers son agent le plus proche.

                Agent aProche = this.getAgentList().get(indexNearAgent); //On recherche l'agent proche dans la liste.

                PVector p1 = this.getAgentList().get(i).getPosition(); //On cherche la position de l'agent "i".
                PVector p2 = aProche.getPosition(); //On recherche la position de l'agent le plus proche.

                if (this.reachLimit(p1, p2)) { //Test si la limite avant la phagocytose est atteinte.
                    this.phagocytose(i, indexNearAgent);
                }
            }
        }
    }

    //---------------------------------
    /** ROLE : Update la position d'un agent donné par son indice dans la liste.
     * @param indexAgent : Représente l'agent. 
     */
    public void updateAgent(int indexAgent, int indexNearAgent) {
        Agent a         = this.getAgentList().get(indexAgent); //On récupère l'agent à déplacer dans la liste.
        Agent nearAgent = this.getAgentList().get(indexNearAgent); //On récupère l'agent le plus proche.

        a.update(nearAgent); //On calcule la distance de rapprochement entre l'agent "a" et son agent le plus proche, puis on les rapproche avec un coeff donné.
    }

    //************************************* PHAGOCYTOSE ************************************************
    /** ROLE : Sert de lancement de la Phagocytose entre 2 agents.
     * Calcul si 2 agents on atteint la limite pour acceder à l'étape de la phagocytose.
     *
     * @param p1 : Représente l'agent testé.
     * @param p2 : Représente l'agent le plus proche de l'agent testé.
     * @return boolean
     */
    public boolean reachLimit(PVector p1, PVector p2){

        float distanceAgentToAgent =
                sqrt(((p1.x - p2.x) * (p1.x - p2.x)) +
                        (p1.y - p2.y) * (p1.y - p2.y));
        return distanceAgentToAgent <= this.limitPhagocytose ;
    }

    //---------------------------------
    /** Permet à partir d'un certaine limite de "phagocyter" 2 agents.
     * C'est à dire qu'il y a création d'un nouvel agent, ayant pour Aire l'addition des 2 autres agents.
     *
     * @param ind1 : Représente l'agent se rapprochant.
     * @param ind2 : Représente l'agent le plus proche.
     */
    public void phagocytose(int ind1, int ind2) {
        //VARIABLE
        //Recherche des agents correspondant aux indices.
        Agent a = this.getAgentList().get(ind1);
        Agent b = this.getAgentList().get(ind2);

        //Recreer un nouveau centre au milieu des positions des agents a et b.
        float x = middleDistance(a.getPosition().x, b.getPosition().x);
        float y = middleDistance(a.getPosition().y, b.getPosition().y);
        PVector nouvP = new PVector(x, y); //Création de la nouvelle position.

        //Nouveau diamètre.
        float nouvdiameter = this.diameterNewAgent(a, b);

        //Couleur a et b.
        int a_color = a.getC1();
        int b_color = b.getC1();

        //DEBUT
        //Suppresion des agent a et b.
        //Attention, on supprime avant l'agent ayant le plus grand indice dans la liste !
            if (ind1 < ind2) {
                this.getAgentList().remove(b);
                this.getAgentList().remove(a);
            } else {
                this.getAgentList().remove(a);
                this.getAgentList().remove(b);
            }
            this.getAgentList().add(new Agent(nouvP, nouvdiameter, a_color, b_color, a.getAlpha(), b.getAlpha())); //Création du nouvel agent, plus grand.
    }

    //---------------------------------
    /** Calcul la valeur médiane entre 2 float.
     *
     * @param x1 : Premiere valeur.
     * @param x2 : Premiere valeur.
     * @return float : moyenne de x1 et x2.
     */
    public float middleDistance(float x1, float x2){
        return (x1 + x2) / 2;
    }


    //---------------------------------
    /** ROLE : Calcul le diameter à partir de l'addition de l'aire entre 2 agents.
     *
     * @param a : 1er agent.
     * @param b : 2er agent.
     * @return float : diameter correspondant a l'addition des aires de "a" et "b".
     */
    public float diameterNewAgent(Agent a , Agent b){
        float aire = areaNewAgent(a, b);
        return ( 2 * sqrt(aire)  / sqrt(PI));
    }

    //---------------------------------
    /** ROLE : Calcul et additionne l'aire de 2 agents.
     *
     * @param a : 1er agent.
     * @param b : 2er agent.
     * @return float : Représente l'addition de l'aire des agents "a" et "b".
     */
    public float areaNewAgent(Agent a , Agent b){
        return PI * (a.getDiameter()/2 * ( a.getDiameter()/2) ) + PI* (b.getDiameter()/2 * (b.getDiameter()/2) );
    }


    //*************************************** MOUSE CLICKED ***************************************
    /** ROLE : Permet la création d'un agent à chaque clique sur l'écran, d'affichage.
     * Cette fonction permet de superposer 2 agents contrairement à intiAgent(). */
    public void newAgent(){
        //On donne un diametre random pour chaque agent.
        this.diameterAgent = (int) random(10,20);

        PVector pos = new PVector (mouseX, mouseY); //Création du centre à partir des coordonnées de la souris.
        Agent a = new Agent(pos, this.diameterAgent); //Création du nouvel agent.
        this.getAgentList().add(a); //Ajout dans la liste.
    }
}
