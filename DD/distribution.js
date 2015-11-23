for each zone in zones{
  historicalAvg = getHistData(now.date, now.hour, zone);
  currentAvg = getLastHourData(zone);
  taxiesToMove = ((historicalAvg*weightOne+currentAvg*weightTwo)*zone.getWeight())/2 - zone.getTaxies();
  zone.getQueue().setTaxiesToMove(taxiesToMove);
}

surplusQueues = [];
deficitQueues = [];

while(i < surplusQueues.length  && j< deficitQueues.length){
  if(surplusQueues[i].getTaxiesToMove > deficitQueues[j].getTaxiesToMove){
    deficitQueues[j].setTaxiesToMove(0);
    surplus[i].setTaxiesToMove(oldValue-deficitQueues[j].getTaxiesToMove);
    j++;
    //move actual taxies between queues
    //send order
  }
  else if(surplusQueues[i].getTaxiesToMove < deficitQueues[j].getTaxiesToMove){
    serplus[i].setTaxiesToMove(0);
    deficit[j].setTaxiesToMove(oldValue-surplus[j].getTaxiesToMove);
    i++;
    //move actual taxies between queues
    //send order
  }
  else{
    serplus[i].setTaxiesToMove(0);
    deficit[j].setTaxiesToMove(0);
    i++;
    j++;
    //move actual taxies between queues
    //send order
  }
  deficitQueuesurplusQueues[i].getTaxiesToMove
}
