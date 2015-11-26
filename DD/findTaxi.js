/**
  Checks if there exists a mtaxi in the queue relative to the specified zone.
  This mtaxi is checked to be at most at the limitTo position from the top of the queue above mentioned.
  This taxi is checked to be  in the conditions of fullfilling a ride request(that means that the traffic condition
  relative to its location is good)
  @param zone The zone relative to the ride request to be fullfilled
  @param limitTo The upper bound limit on the position of a mtaxi from the top of its queue so that it can be selected
  to fullfill a ride request
  @return firstInQueue The mtaxi selected following the criteria above mentioned
  @return -1 If it does not exists a mtaxi that can be selected using the criteria above mentioned

**/
function checkTaxi(zone,limitTo){
  //Gets the queue relative to the zone specified
  var queue = findQueueByZone(zone);
  var i=0;
  var firstInQueue = queue.dequeue();
  //The queue must be non empty, the amount of mtaxies in bad traffic conditions
  //must not be equal to the number of all mtaxies in the queue, i must not consider
  //mtaxies whose position from the top of the queue exceeds the given limitTo
  while(!queue.isEmpty && i<limitTo && queue.puttedBottom !== queue.length){
    //Checks traffic conditions
    if(LocationManager.checkTrafficByTaxi(firstInQueue)!== 'HIGH'){
      return firstInQueue;
    }
    else{
      //Puts a mtaxi in bad traffic condition on the bottom of the queue
      queue.putInBottom(firstInQueue);
      i++;
    }
  }
  return -1;
}


/**
Checks if there exists a mtaxi in the queue relative to the specified zone or to
the zones adjacent to the one specified or to the zones adjacent to the ones adjacent to the one initially
specified(depth = 2)
@param zone The zone relative to the ride request to be fullfilled
@param firstLimitTo The upper bound limit on the position of a mtaxi from the top of its queue so that it can be selected
to fullfill a ride request
**/
function seachTaxi(zone,limitTo){
  //Helper queues
  firstHelperQueue = [];
  secondHelperQueue = [];
  thirdHeleprQueue = [];

  //depth = 0
  //checking mtaxies
  result = checkTaxi(zone,limitTo);

  if(result !== -1){
    return result;
  }
  else{
    //depth = 1
    //fills the first and second helper queue with the zones
    //adjacent to the given one
    foreach(z in zone.adjacentZones){
      firstHelperQueue.push(z);
      secondHelperQueue.push(z);
    }
    //extracts the adjacent zones and checks them for mtaxies
    while(firstHelperQueue.length !== 0){
      zone = firstHelperQueue.pop();
      result = checkTaxi(zone,limitTo);
      if(result !== -1){
        return result
      }
    }
    //depth = 2
    while(secondHelperQueue.length !== 0){
      zone = secondHelperQueue.pop();
      //fills the third helper queue with the zones adjacent to the ones
      //adjacent to the initial one
      foreach(z in zone.adjacentZones){
        thirdHeleprQueue.push(z)
      }
      //extracts the adjacent zones and checks them for mtaxies
      while(thirdHeleprQueue.length !== 0){
        zone = thirdHeleprQueue.pop();
        result = checkTaxi(zone, limitTo);
        if(result !== -1){
          return result
        }
      }
      //empties the third helper queue
      thirdHeleprQueue.flush();
    }
    //no taxi found also going deep in the analysis
    return -1;
  }
