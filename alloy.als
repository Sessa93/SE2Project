sig Integer{}
sig Strings{}

sig Location{
	address : one Strings,
	longitudeRange: one Strings,
	latitudeRange: one Strings
}

abstract sig Person {
	name : one Strings,
	lastName: one Strings
}

abstract sig TaxiState{}
abstract sig UserState{}

sig User extends Person {}

sig RegisteredUser extends Person {
	email : one Strings,
	password: one Strings,
	rideRequest: lone RideRequest,
	bookingRequest: set BookingRequest,
	userState: one UserState
}


one sig Available, Unavailable extends TaxiState {}
one sig Logged, NonLogged extends UserState {}

sig TaxiDriver extends Person {}

sig MtaxiDriver extends TaxiDriver{
	workTimeTable : one WorkTimeTable,
	taxi : one Mtaxi,
	request : lone Request,
	state : one TaxiState
}
abstract sig Request{
	id : one Integer,
	numPassengers: one Integer,
	taxi : one Mtaxi
}
sig RideRequest extends Request {
	user : one RegisteredUser
}
sig BookingRequest extends Request{
	user : one RegisteredUser,
	date : one Strings,
	time: one Strings
}
sig Mtaxi {
	id : one Integer,
	licensePlateNumber: one Strings,
	capacity: one Integer,
	model: one Strings,
	brand: one Strings,
	driver: one MtaxiDriver
}
sig Queue {
	id : one Strings,
	taxies: set Mtaxi,
	zone : one Zone
}
sig Zone {
	id: one Strings,
	locations: some Location
}
sig WorkTimeTable {
	startingTime: one Strings,
	endingTime: one Strings,
	startingLunchTime: one Strings,
	endingEndTime: one Strings
}

//FACTS
fact DiffRideRequestDiffTaxi {
	all r1, r2 : RideRequest | r1!=r2  implies	r1.taxi  != r2.taxi
}
fact zoneQueue {
	all z : Zone | one q: Queue | q.zone = z
}
fact DiffQueuesDiffZones {
	all q1, q2 : Queue | 	q1!=q2  implies	q1.zone  != q2.zone
}
fact DiffRequestDiffId {
	all r1, r2 : Request | 	r1!=r2  implies 	r1.id  != r2.id
}
fact DiffTaxiDiffId {
	all t1, t2 : Mtaxi | 	t1!=t2  implies 	t1.id  != t2.id
}
fact DiffUsersDiffMail {
	all u1, u2 : RegisteredUser | 	u1!=u2  implies 	u1.email  != u2.email
}
fact DiffReqsDiffUsers {
	all r1, r2 : RideRequest | r1!=r2  implies 	r1.user  != r2.user
}
fact DiffBooksDiffUsers {
	all r1, r2 : BookingRequest | r1!=r2  implies 	r1.user  != r2.user
}
fact RequestLoggedReg_1 {
	all r : RideRequest | (r.user).userState = Logged
}
fact BookingLoggedReg_2 {
	all r : BookingRequest | (r.user).userState = Logged
}

fact BookingLoggedReg_3{
	all u : RegisteredUser, r: RideRequest | u.rideRequest=r iff r.user = u
}

//ASSERT
assert checkDiffRideRequestDiffTaxi {
	
}
pred show {
	#RegisteredUser = 2
	#RideRequest > 1
	#Mtaxi > 1
}
run show for 5
