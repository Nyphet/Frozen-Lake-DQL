class Agent
{
  int x; //Agent icon x coordinate.
  int y; //Agent icon y coordinate.
  int dim; //Agent icon dimension.
  
  boolean done; //True if the current game reached a terminal state, false otherwise.
  boolean outOfMap; //True if the Agent went out of the map, false otherwise.
  
  double discountFactor = 0.9;
  double explorationRate = 1;
  double explorationDecay = (double)1/gameData.gamesThreshold;
  
  Brain brain = new Brain(cellNum, cellNum/2, 4, 0.1); //Neural Network.
  
  public Agent(int dim)
  {
    this.reset();
    this.dim = dim;
  }
  
  public void train()
  {
    lake.render(); //Draw Environment.
    agent.render(); //Draw Agent.
    if(!done) //If game is not completed.
    {
      //Get Agent state (array of doubles, all 0s except the cell the Agent is on that's 1).
      double[] state = getState();
      
      Layer[] oldNeurons = brain.estimateOutput(state); //Hidden neurons [0] + Output neurons [1].
      
      int action = getAction(oldNeurons[1]); //Choose the action with the highest reward value predicted.
      
      gameData.gameMoves++; //Increase the moves done for this game.
      double reward = move(action); //Take the action and get the reward.
      
      Layer previsions = brain.estimateOutput(getState())[1]; //Output neurons.
      
      Layer desiredOutput = new Layer(oldNeurons[1].layer[0]); //Save the predicted rewards for the initial state.
      
      desiredOutput.layer[0][action] = reward + discountFactor*previsions.getMaxValue(); //Update the reward for the action taken.
      
      brain.learn(new Layer(state), oldNeurons, desiredOutput); //Make the NN learn.
    }
    else
    {
      explorationRate -= explorationDecay; //Decrease the exploration rate at every game completed.
      newGame(); //Update gameData object and draw Neural Network.
      reset(); //Set the Agent back to the start position.
    }
  }
  
  public void play()
  {
    lake.render(); //Draw Environment.
    agent.render(); //Draw Agent.
    if(!done)
    {
      //Get Agent state (array of doubles, all 0s except the cell the Agent is on that's 1).
      double[] state = getState();
      int action = getAction(brain.estimateOutput(state)[1]); //Choose the action with the highest reward value predicted.
      gameData.gameMoves++; //Increase the moves done for this game.
      move(action); //Take the action.
    }
    else
    {
      newGame(); //Update gameData object and draw Neural Network.
      reset(); //Set the Agent back to the start position.
    }
  }
  
  //Choose an action to take depending on the state passed as parameter and whether the Agent is training or playing.
  public int getAction(Layer layer)
  {
    if(random(0, 1) < explorationRate)
    {
      return (int)random(0, 4); //Random action.
    }
    else
    {
      return layer.getMaxPosition(); //Best action.
    }
  }
  
  //Move the Agent depending on the action passed as parameter and after update the Environment that the Agent moved.
  public double move(int action)
  {
    switch(action)
    {
      case 0: //Left.
        x -= cellDim;
        break;
      case 1: //Up.
        y -= cellDim;
        break;
      case 2: //Right.
        x += cellDim;
        break;
      case 3: //Down.
        y += cellDim;
        break;
    }
    return lake.moved();
  }
  
  //Return an array of double containing all 0s except for the cell the Agent is on that's 1.
  private double[] getState()
  { 
    double[] state = new double[cellNum];
    for(Cell cell : lake.cells)
    {
      if((x - cellDim/2) == cell.x && (y - cellDim/2) == cell.y)
      {
        state[lake.cells.indexOf(cell)] = 1;
      }
      else
      {
        state[lake.cells.indexOf(cell)] = 0;
      }
    }
    return state;
  }
  
  //Draw Agent icon.
  public void render()
  {
    if(outOfMap)
    {
      noStroke();
      fill(150);
      ellipse(x, y, dim, dim);
    }
  }
  
  //Update gameData object and draw Neural Network.
  public void newGame()
  {
    this.brain.render(new Layer(1, cellNum), new Layer(1, cellNum/2), new Layer(1, 4));
    gameData.increaseGames(); //Increase games played.
    gameData.printData(); //Print game data.
    gameData.gameMoves = 0; //Set moves for the next game to 0.
  }
  
  //Set the Agent back to the starting state.
  public void reset()
  {
    x = cellDim/2;
    y = cellDim/2;
    done = false;
    outOfMap = true;
  }
}
