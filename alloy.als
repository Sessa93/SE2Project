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
fact RequestLoggedUser {
	all r : RideRequest | (r.user).userState = Logged
}
fact BookingLoggedUser {
	all r : BookingRequest | (r.user).userState = Logged
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
fact DiffLocationDiffAddress {
	all l1, l2: Location | l1 != l2 implies l1.address != l2.address
}
fact AvailableTaxiRequest {
	all r: RideRequest | some t: Mtaxi | r.taxi = t and t.driver.state = Available
}
fact OneDriverOneTaxi {
	all t: Mtaxi, d: MtaxiDriver | t.driver = d iff d.taxi = t
}

//ASSERT
assert  NoRequestWithoutUserDriver {
	all r: RideRequest | some u: RegisteredUser, d: Mtaxi | r.taxi = d and r.user = u 
}
check  NoRequestWithoutUserDriver for 5

assert NoBookingReqWithoutUserDriver {
	all r: BookingRequest | some u: RegisteredUser, d: Mtaxi | r.taxi = d and r.user = u 
}
check  NoBookingReqWithoutUserDriver for 5

assert NoMtaxiWithoutDriver {
	all t: Mtaxi | some d: MtaxiDriver | t.driver = d
}
check NoMtaxiWithoutDriver for 5

assert NoUnavailableTaxiToRequest {
	all t: Mtaxi, r: RideRequest | no d : MtaxiDriver | t.driver = d and d.state = Unavailable and r.taxi = t
}
check NoUnavailableTaxiToRequest for 5

//Predicates section

//General world generation
pred show {
	#RegisteredUser = 2
	#RideRequest = 1
	#Mtaxi = 1
}
run show for 5

//Show a world in which there are no taxi available but some user has made a BookingRequest
pred  NoTaxiAvailable {
	some u: RegisteredUser, r: BookingRequest | r.user = u
	no t: Mtaxi, d: MtaxiDriver | t.driver = d and d.state = Available
	#Mtaxi > 1
	#MtaxiDriver > 1
}
run NoTaxiAvailable for 5

//Show a world which enlights ride/booking request properties
pred RideBookingRequestProperties {
	#Mtaxi = 2
	#MtaxiDriver = 2
	all d: MtaxiDriver | d.state = Available
	#RideRequest = 1
	#BookingRequest = 1
}
run RideBookingRequestProperties for 5






