//We suppose to snapshot the status of the system in a specific time and to consider as if requests have been just made

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
	taxi: lone Mtaxi,
	date : one Strings,
	time: one Strings
}
sig Mtaxi {
	id : one Integer,
	licensePlateNumber: one Strings,
	capacity: one Integer,
	model: one Strings,
	brand: one Strings,
	driver: one MtaxiDriver,
	state : one TaxiState
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
	endingLunchTime: one Strings
}

//FACTS
fact DiffRideRequestDiffTaxi {
	all r1, r2 : RideRequest | r1!=r2  implies	r1.taxi  != r2.taxi
}
fact DiffBookingRequest {
	all r1, r2 : BookingRequest | r1!=r2 and #r1.taxi = 1 and #r2.taxi = 1  implies	r1.taxi  != r2.taxi
}
fact DiffBookingRide {
 	all r1 : RideRequest, r2: BookingRequest |	r1.taxi  != r2.taxi
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
fact RequestLoggedUser {
	all r : Request | (r.user).userState = Logged
}

fact BookingLoggedReg_3{
	all u : RegisteredUser, r: RideRequest | u.rideRequest=r iff r.user = u
}
fact DiffQueuesDiffID {
	all q1, q2: Queue | q1 != q2 implies q1.id != q2.id
}
fact DiffZonesDiffLocation {
	all z1, z2: Zone | z1 != z2 implies no l: Location | l in z1.locations and l in z2.locations
}
fact LocationConstency {
	all l1, l2: Location | l1 != l2 implies l1.address != l2.address
	all l1, l2: Location | l1 != l2 implies l1.longitudeRange != l2.longitudeRange
	all l1, l2: Location | l1 != l2 implies l1.latitudeRange != l2.latitudeRange
}
fact AvailableTaxiRequest {
	all r: RideRequest | some t: Mtaxi | r.taxi = t and t.state = Available
}
fact OneDriverOneTaxi {
	all t: Mtaxi, d: MtaxiDriver | t.driver = d iff d.taxi = t
}
fact DifferentLocations {
	all r: Request | r.startingLocation != r.endingLocation
}
fact WorktimeTableConsistency {
	all w: WorkTimeTable | w.startingTime !=  w.endingTime
	all w: WorkTimeTable | w.startingLunchTime !=  w.endingLunchTime
}
fact noUsersToSameBookingreq {
	all u: RegisteredUser | all b1,b2:BookingRequest | b1 != b2 and b2 in u.bookingRequest and b1 in u.bookingRequest implies b2.date != b1.date and b2.time != b1.time 
}
fact queuesOfAvailableTaxies {
	all q: Queue | all t: Mtaxi | t in q.taxies and t.state = Available
}
//ASSERT
assert  NoRequestWithoutUserDriver {
	all r: RideRequest | some u: RegisteredUser, t: Mtaxi | r.taxi = t and r.user = u 
}
check  NoRequestWithoutUserDriver for 5

assert NoUserUbiquos {
	all u: RegisteredUser | no b1,b2 : BookingRequest | b1 != b2 and b1 in u.bookingRequest and b2 in u.bookingRequest and b1.date = b2.date and b1.time  = b2.time
}
check NoUserUbiquos for 5
assert NoMtaxiWithoutDriver {
	all t: Mtaxi | some d: MtaxiDriver | t.driver = d
}
check NoMtaxiWithoutDriver for 5

assert NoUnavailableTaxiToRequest {
	all t: Mtaxi, r: RideRequest | t.state = Available and r.taxi = t
}
check NoUnavailableTaxiToRequest for 5

//Predicates section

//General world generation
pred show {
	#RegisteredUser = 2
	#RideRequest = 1
	#BookingRequest = 1
	#Mtaxi > 1
}
run show for 5

//Show a world in which there are no taxi available but some user has made a BookingRequest
pred  NoTaxiAvailable {
	some u: RegisteredUser, r: BookingRequest | r.user = u
	no t: Mtaxi | t.state = Available
	#Mtaxi > 1
	#MtaxiDriver > 1
}
run NoTaxiAvailable for 5

//Show a world which enlights ride/booking request properties
pred RideBookingRequestProperties {
	#Mtaxi = 2
	#MtaxiDriver = 2
	all d: Mtaxi | d.state = Available
	#RideRequest = 1
	#BookingRequest = 1
}
run RideBookingRequestProperties for 5




