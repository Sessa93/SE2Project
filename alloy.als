//START ENTITIES

//Models integer values
sig Integer{}
//Models string values
sig Strings{}


abstract sig Person {
	name : one Strings,
	lastName: one Strings
}

sig User extends Person {}

sig RegisteredUser extends Person {
	email : one Strings,
	password: one Strings,
	rideRequest: lone RideRequest,
	bookingRequest: set BookingRequest,
	userState: one UserState
}

abstract sig UserState{}

one sig Logged, NonLogged extends UserState {}

sig Mtaxi {
	id : one Integer,
	licensePlateNumber: one Strings,
	capacity: one Integer,
	model: one Strings,
	brand: one Strings,
	driver: one MtaxiDriver,
	state : one TaxiState
}

abstract sig TaxiState{}

one sig Available, Unavailable extends TaxiState {}

sig TaxiDriver extends Person {}

sig MtaxiDriver extends TaxiDriver{
	workTimeTable : one WorkTimeTable,
	taxi : one Mtaxi,
}

abstract sig Request{
	id : one Integer,
	numPassengers: one Integer,
	startingLocation : one Location,
	endingLocation: one Location,
	user : one RegisteredUser
}

sig RideRequest extends Request {
	taxi : one Mtaxi,
}

sig BookingRequest extends Request{
	taxi: lone Mtaxi, //MOD
	date : one Strings,
	time: one Strings
}

sig Location {
	address : one Strings,
	longitudeRange: one Strings,
	latitudeRange: one Strings
}

sig Zone {
	id: one Strings,
	locations: some Location
}

sig Queue {
	id : one Strings,
	taxies: set Mtaxi,
	zone : one Zone
}

sig WorkTimeTable {
	startingTime: one Strings,
	endingTime: one Strings,
	startingLunchTime: one Strings,
	endingLunchTime: one Strings
}
//ENDING ENTITIES

//STARTING FACTS
// D -> Different
//Different requests correspond to different mtaxies
fact DRequestsDMtaxies  {
	//Different requests correspond to different mtaxies
	all r1, r2 : RideRequest | r1!=r2  implies	r1.taxi  != r2.taxi
	//Different booking requests correspond to different mtaxies if these two different requests are associated to two taxies
	all r1, r2 : BookingRequest | r1!=r2  implies	r1.taxi  != r2.taxi
	//Mixed case
	all r1 : RideRequest, r2: BookingRequest | r1.taxi  != r2.taxi
}
//A zone is associated to a specif queue and a queue is associated to a specific zone
fact zonesQueues {
	//Every zone is associated with just one queue
	all z : Zone | one q: Queue | q.zone = z
	//Different queues correspond to different zones
	all q1, q2 : Queue | 	q1!=q2  implies	q1.zone  != q2.zone
}

fact IdsConsistency {
	//Different requests have different request ids
	all r1, r2 : Request | 	r1!=r2  implies 	r1.id  != r2.id
	//Different mtaxies have different mtaxi ids
	all t1, t2 : Mtaxi | 	t1!=t2  implies 	t1.id  != t2.id
	//Different queues have different ids
	all q1, q2: Queue | q1 != q2 implies q1.id != q2.id
}
//Different registered users have different emails
fact DUsersDMails {
	all u1, u2 : RegisteredUser | 	u1!=u2  implies 	u1.email  != u2.email
}
//Different requests are associated to different users
fact DRideRequestsDUsers {
	//Ride requests case
	all r1, r2 : RideRequest | r1!=r2  implies 	r1.user  != r2.user
	//Booking request case
	all r1, r2 : BookingRequest | r1!=r2  implies 	r1.user  != r2.user
}
//A ride request has to be performed by a logged user
fact RequestLoggedUser {
	all r : RideRequest | (r.user).userState = Logged
}
//If a registered user is associated with a request than that request is associated with that user
fact TwoWayBindingUserRequests{
	//Ride requests case
	all u : RegisteredUser, r: RideRequest | u.rideRequest=r iff r.user = u
	//Booking requests case
	all u : RegisteredUser, r: BookingRequest | u.bookingRequest = r iff r.user = u
}
//Two different zones aggregate different locations
fact DZonesDLocations {
	all z1, z2: Zone | z1 != z2 implies no l: Location | l in z1.locations and l in z2.locations
}
fact LocationConstency {
	//Two different location can't have the same address
	all l1, l2: Location | l1 != l2 implies l1.address != l2.address
	//Like above but for longitude range
	all l1, l2: Location | l1 != l2 implies l1.longitudeRange != l2.longitudeRange
	//Like above but for latitude range
	all l1, l2: Location | l1 != l2 implies l1.latitudeRange != l2.latitudeRange
}
//Only available mtaxies can fullfil a requests
fact RideRequestAvailableMtaxi {
	//Ride requests case
	all r: RideRequest | (r.taxi).state = Available
	//Booking requests case
	all r: BookingRequest | (r.taxi).state = Available
}
//If a mtaxi is associated with a mtaxi driver than that driver is associated with that mtaxi
fact OneDriverOneTaxi {
	all t: Mtaxi, d: MtaxiDriver | t.driver = d iff d.taxi = t
}
//A request has a diffrent start and ending location
fact DStartingEndingLocations {
	all r: Request | r.startingLocation != r.endingLocation
}
fact WorktimeTableConsistency {
	//All mtaxies are actually supposed to work
	all w: WorkTimeTable | w.startingTime !=  w.endingTime
	//All mtaxies are actually supposed to have time to have lunch
	all w: WorkTimeTable | w.startingLunchTime !=  w.endingLunchTime
}
//A registered user can't book two or more taxies for the same date and time
fact NonUbiquosUsers {
	all u: RegisteredUser | all b1,b2:BookingRequest | b1 != b2 and b2 in u.bookingRequest and b1 in u.bookingRequest implies b2.date != b1.date and b2.time != b1.time 
}
//A queue aggregates only available mtaxies
fact queuesOfAvailableTaxies {
	all q: Queue | all t: Mtaxi | t in q.taxies and t.state = Available
}

//START ASSERTIONS

assert  NoRequestsWithoutUserOrMtaxies {
	//RideRequest case
	all r: RideRequest | one u: RegisteredUser, t: Mtaxi | r.taxi = t and r.user = u 
	//BookingRequest case
	all r: BookingRequest | one u: RegisteredUser, t: Mtaxi | r.taxi = t and r.user = u 
}
check  NoRequestsWithoutUserOrMtaxies for 5

assert NoUserUbiquos {
	all u: RegisteredUser | no b1,b2 : BookingRequest | b1 != b2 and b1 in u.bookingRequest and b2 in u.bookingRequest and b1.date = b2.date and b1.time  = b2.time
}
check NoUserUbiquos for 5

assert NoMtaxiWithoutDriver {
	all t: Mtaxi | one d: MtaxiDriver | t.driver = d
}
check NoMtaxiWithoutDriver for 5

assert RequestsMapOnlyAvailableMtaxies {
	//Ride request case
	all r: RideRequest | (r.taxi).state = Available
	//Booking request case
	all r: BookingRequest | (r.taxi).state = Available
}
check RequestsMapOnlyAvailableMtaxies for 5

//Verify that remove and add operations are consistent
assert DelUndoAdd {
	all q,q',q'': Queue, t: Mtaxi | addTaxiToQueue[q,q',t] and delTaxiFromQueue[q',q'',t] implies q.taxies = q''.taxies
}
check DelUndoAdd for 5

//ENDING ASSERTIONS

//STARTING PREDICATES

//Simulates the add of a taxi to a queue
pred addTaxiToQueue(q,q': Queue, t: Mtaxi) {
	q'.taxies = q.taxies + t
}
run  addTaxiToQueue for 5

//Simulates the deletion of a taxi from a queue
pred delTaxiFromQueue(q,q': Queue, t: Mtaxi) {
	q'.taxies = q.taxies - t
}
run  addTaxiToQueue for 5

//General world generation
pred show {
	#RegisteredUser = 2
	#RideRequest = 1
	#BookingRequest = 1
	#Mtaxi = 2
	#WorkTimeTable = 1
}
run show for 5

//Show a world which enlights ride/booking request properties
pred RideBookingRequestProperties {
	#Mtaxi = 2
	#MtaxiDriver = 2
	all d: Mtaxi | d.state = Available
	#RideRequest = 1
	#BookingRequest = 1
	#WorkTimeTable = 1
}
run RideBookingRequestProperties for 3







