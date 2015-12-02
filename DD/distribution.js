/*
  The following algorithm is run in the Queue Manager component periodically(each hour).
  Its objective is to try to reditribute taxies present in the city's zones in order
  to match the expected demand of taxies in each zone.
  To accomplish this objective the first part of the algorithm computes, for each zone,
  the expected demand by means of the following formula:

    expectedTaxies = ((historicalAvg*w1+currentAvg*w2)*zone.getWeight())/2

  This formula is based both on historical data for the current day and time and
  the last hour data registered in the database.
  Each of this two terms is "weighted" (w1,w2) in order to determine how
  the old and new data contributes to the final result.
  The above formula takes also into account the size of the by means of a third
  weight typical of each zone(zone.getWeight()), the more the value is near to 1
  the more the zone is bigger. This is necessary to consider the fact that smaller
  zones in general have a smaller number of request wrt to bigger zones.
  For each zone the number of taxies already present is subtracted from the
  expectedTaxies value(for that zone). This operation produces the taxiesToMove
  variable that if positive indicates a zones that has a "surplus" of taxies and
  if negative indicates a zone with a "deficit" of taxies.
  Queues are then divided into two separated lists(surplusQueues, deficitQueues)
  according to the value of taxiesToMove.
  The lists are sorted according to the value of taxiesToMove.
  The algorithm reditribute the taxies by initially considering the couple of queues which
  has the highest number of taxies in respectively in deficit/surplus.
  The algorithm proceeds by selecting queues with deacreasing number of taxiesToMove.
  The function return when:
    - The expected demand of taxies has been fullfilled
    - There are no more taxies to fullfill the expected demand
*/

// 0 < w1, w2 < 1
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
