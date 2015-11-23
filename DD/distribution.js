
function computeDistribution(float w1, float w2) {
  /*The following for cycle computes, for each zone, the number of taxies
   *required(taxiesToMove < 0) or the number of taxies in surplus(taxiesToMove > 0)
   */
  foreach(zone in zones){
    //Get the average number of requests for the current day/hour
    historicalAvg = getHistData(now.date, now.hour, zone);
    //Get the number of requests registered in the last hour
    currentAvg = getLastHourData(zone);
    //Computes the expected number of taxies required in this zone for the following hour
    taxiesToMove = ((historicalAvg*w1+currentAvg*w2)*zone.getWeight())/2 - zone.getTaxies();
    //Assigns the expected number of taxies to the relevant queue
    zone.getQueue().setTaxiesToMove(taxiesToMove);
  }

  //surplusQueues is the list of queues that has some taxies to offer
  surplusQueues = [/*List of queues with taxiesToMove > 0*/];
  //deficitQueues is the list of queues that requires some taxies
  deficitQueues = [/*List of queues with taxiesToMove < 0*/];

  //Sort surplusQueues by deacreasing taxiesToMove
  Sort(surplusQueues);
  //Sort deficitQueues by deacreasing taxiesToMove
  Sort(deficitQueues);

  //i iterates over surplusQueues
  //j iterates over deficitQueues
  while(i < surplusQueues.length  && j < deficitQueues.length){

    //If the current surplusQueues has more taxies to offer than the current deficitQueues
    if(surplusQueues[i].getTaxiesToMove > deficitQueues[j].getTaxiesToMove){
      deficitQueues[j].setTaxiesToMove(0);
      surplusQueues[i].setTaxiesToMove(oldValue-deficitQueues[j].getTaxiesToMove);
      //Select the next deficitQueues
      j++;
      //Send the order
      foreach(taxi in surplusQueues[i].getTaxies()) {
        moveTaxi(deficitQueues[j],taxi)
      }

    }
    //If the current deficitQueues reuires more than what the current surplusQueues has to offer
    else if(surplusQueues[i].getTaxiesToMove < deficitQueues[j].getTaxiesToMove){
      serplusQueues[i].setTaxiesToMove(0);
      deficitQueues[j].setTaxiesToMove(oldValue-surplus[j].getTaxiesToMove);
      //Send the order
      foreach(taxi in surplusQueues[i].getTaxies()) {
        moveTaxi(deficitQueues[j],taxi)
      }
      //Select the next surplusQueues
      i++;
    }
    //If the current deficitQueues requires exaclty what the current surplusQueues offers
    else{
      serplus[i].setTaxiesToMove(0);
      deficit[j].setTaxiesToMove(0);
      //Send the order
      foreach(taxi in surplusQueues[i].getTaxies()) {
        moveTaxi(deficitQueues[j],taxi)
      }

      //Select the new surplus/deficitQueues 
      i++;
      j++;
      //move actual taxies between queues
      //send order
    }
    deficitQueuesurplusQueues[i].getTaxiesToMove
  }
}

/* Adds taxi to endingQueue
 * Sends a change zone order to taxi via a primitive provided by
 * the Request Manager component
 */
function moveTaxi(endingQueue, taxi) {
  endingQueue.add(taxi);
  sendChangeOrder(taxi);
}
