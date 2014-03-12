/**
 * @file: vehicle.cu
 * @author: Chris Blatchley
 * @author: Thad Bond
 *
 * Vehicle object implementation
 */
#pragma once
#include "vehicle.cuh"
#include "route.cuh"

const float Vehicle::ACCEL_FACTOR = 5.0;
const float Vehicle::CRUISE_ACCEL = 0.0;
const int Vehicle::MIN_CAR_LENGTHS_IN_FRONT = 2;

/**
 * Class Constructor and Destructor
 */
Vehicle::Vehicle( Route* route, Vehicle::Style style, int depart )
{
	Vehicle::route = route;
	Vehicle::style = style;
	Vehicle::depart = depart;
}

Vehicle::~Vehicle()
{

}

/**
 * Logic to occur when the vehicle enters a new lane
 * @param lane The lane being entered
 */
void Vehicle::enterLane(Lane *lane)
{
    pos = 0;
    currEdge = lane->edge;
}

/**
 * Called on each vehicle to plan the next move
 * @param pred     The vehicle infront of this one
 * @param distance The distance between this vehicle and it's predecessor
 */
void Vehicle::planMove(Vehicle* pred, float distance)
{
    float accelFactor = CRUISE_ACCEL;
    float distanceToStop = currEdge->length - pos;
    float timeToStop = currSpeed / ACCEL_FACTOR;
    float stoppingDistance = timeToStop * (timeToStop + 1) * currSpeed / 2.0;

    bool approachingStop = distanceToStop < stoppingDistance;
    bool approachingPred = (pred && pred->currSpeed <= currSpeed);
    bool predIsSlower = (pred && pred->style.speed < style.speed);
    bool withinCarBuffer = (distance <= style.length * MIN_CAR_LENGTHS_IN_FRONT);
    bool canStopNow = currSpeed <= ACCEL_FACTOR;
    bool wantsToAccel = currSpeed < style.speed;

    if( approachingStop && !canStopNow or approachingPred)
    {
        if(predIsSlower)
            accelFactor = pred->currSpeed - currSpeed;
        else
            accelFactor = -1 * ACCEL_FACTOR;
    }
    else if( wantsToAccel && !approachingStop)
    {
        accelFactor = ACCEL_FACTOR;
    }

    currSpeed = currSpeed + accelFactor;
    nextPos = pos + currSpeed;
}

/**
 * Carry out the movement planned in planMove
 */
void Vehicle::executeMove()
{
    pos = nextPos;
}
