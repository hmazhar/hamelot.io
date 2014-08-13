---
title: Using Bullet Only For Collision Detection
date: '2014-08-12'
description:
categories: [programming]
tags: [contact, programming, bullet]
---

Bullet Physics is a great library for adding physics to a game, it can also be used purely as a collision detection tool. I wanted to document the simplest way to set bullet up for collision detection, and then get the contact information back from bullet.

There is nothing special about the code, but I wanted to have it here for my own reference

<pre>

btCollisionConfiguration* bt_collision_configuration;
btCollisionDispatcher* bt_dispatcher;
btBroadphaseInterface* bt_broadphase;
btCollisionWorld* bt_collision_world;

double scene_size = 500;
unsigned int max_objects = 16000;

bt_collision_configuration = new btDefaultCollisionConfiguration();
bt_dispatcher = new btCollisionDispatcher(bt_collision_configuration);

btScalar sscene_size = (btScalar) scene_size;
btVector3 worldAabbMin(-sscene_size, -sscene_size, -sscene_size);
btVector3 worldAabbMax(sscene_size, sscene_size, sscene_size);
//This is one type of broadphase, bullet has others that might be faster depending on the application
bt_broadphase = new bt32BitAxisSweep3(worldAabbMin, worldAabbMax, max_objects, 0, true);  // true for disabling raycast accelerator

bt_collision_world = new btCollisionWorld(bt_dispatcher, bt_broadphase, bt_collision_configuration);
//Create two collision objects
btCollisionObject* sphere_A = new btCollisionObject();
btCollisionObject* sphere_B = new btCollisionObject();
//Move each to a specific location
sphere_A->getWorldTransform().setOrigin(btVector3((btScalar) 2, (btScalar) 1.5, (btScalar) 0));
sphere_B->getWorldTransform().setOrigin(btVector3((btScalar) 2, (btScalar) 0, (btScalar) 0));
//Create a sphere with a radius of 1
btSphereShape sphere_shape(1);
//Set the shape of each collision object
sphere_A->setCollisionShape(&sphere_shape);
sphere_B->setCollisionShape(&sphere_shape);
//Add the collision objects to our collision world
bt_collision_world->addCollisionObject(sphere_A);
bt_collision_world->addCollisionObject(sphere_B);

//Perform collision detection
bt_collision_world->performDiscreteCollisionDetection();

int numManifolds = bt_collision_world->getDispatcher()->getNumManifolds();
//For each contact manifold
for (int i = 0; i < numManifolds; i++) {
  btPersistentManifold* contactManifold = bt_collision_world->getDispatcher()->getManifoldByIndexInternal(i);
  btCollisionObject* obA = static_cast<btCollisionObject*>(contactManifold->getBody0());
    btCollisionObject* obB = static_cast<btCollisionObject*>(contactManifold->getBody1());
    contactManifold->refreshContactPoints(obA->getWorldTransform(), obB->getWorldTransform());
    int numContacts = contactManifold->getNumContacts();
    //For each contact point in that manifold
    for (int j = 0; j < numContacts; j++) {
      //Get the contact information
        btManifoldPoint& pt = contactManifold->getContactPoint(j);
        btVector3 ptA = pt.getPositionWorldOnA();
        btVector3 ptB = pt.getPositionWorldOnB();
        double ptdist = pt.getDistance();
    }
}


</pre>