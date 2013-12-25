---
title: Three.js Quaternion Camera
date: '2013-12-25'
description: A three.js quaternion based free movement camera class
categories: [visualization]
tags: [three.js, camera, javascript, quaternion]
---
This is a three.js camera class based on my quaternion camera code, math is very similar with syntax changes due to vector and quaternion classes in three.js

based on https://github.com/mrdoob/three.js/blob/master/examples/js/controls/PointerLockControls.js

<pre>
/**
 * @author hammad mazhar / http://hamelot.co.uk/
 */
THREE.FreeCamera = function (camera) {

    var scope = this;

    camera.rotation.set(0, 0, 0);
    camera.position.set(0, 1, 0);
    camera.useQuaternion = true;

    var MOVE = {
        LEFT: {
            value: 0,
            name: "Left",
            code: "L"
        },
        RIGHT: {
            value: 1,
            name: "Right",
            code: "R"
        },
        FORWARD: {
            value: 2,
            name: "Forward",
            code: "F"
        },
        BACK: {
            value: 3,
            name: "Back",
            code: "B"
        },
        UP: {
            value: 4,
            name: "Up",
            code: "U"
        },
        DOWN: {
            value: 5,
            name: "Down",
            code: "D"
        }
    };
    var camera_scale = .5;
    var camera_direction = new THREE.Vector3(0, 0, 1);
    var camera_up = new THREE.Vector3(0, 1, 0);
    var camera_position_delta = new THREE.Vector3(0, 0, 0);
    var camera_position = new THREE.Vector3(0, 0, 0);
    var camera_look_at = new THREE.Vector3(0, 0, 2);

    var max_pitch_rate = 5.0;
    var max_heading_rate = 5.0;
    var camera_pitch = 0.0;
    var camera_heading = 0.0;

    var mouse_delta_x = 0.0;
    var mouse_delta_y = 0.0;
    var mouse_pos_x = 0.0;
    var mouse_pos_y = 0.0;
    var move_camera = false;

    var isOnObject = false;
    var canJump = false;

    var onMouseMove = function (event) {
        if (scope.enabled === false) return;

        var movementX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
        var movementY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;

        mouse_delta_x = mouse_pos_x - movementX;
        mouse_delta_y = mouse_pos_y - movementY;
        if (move_camera) {
            ChangeHeading(.08 * mouse_delta_x);
            ChangePitch(.08 * mouse_delta_y);
        }
        mouse_pos_x = movementX;
        mouse_pos_y = movementY;

    };
    var onMouseDown = function (event) {
        var movementX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
        var movementY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;
        mouse_pos_x = movementX;
        mouse_pos_y = movementY;
        move_camera = true;
    }
    var onMouseUp = function (event) {
        var movementX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
        var movementY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;
        mouse_pos_x = movementX;
        mouse_pos_y = movementY;
        move_camera = false;
    }
    var ChangePitch = function (degrees) {
        if (degrees < -max_pitch_rate) {
            degrees = -max_pitch_rate;
        } else if (degrees > max_pitch_rate) {
            degrees = max_pitch_rate;
        }
        camera_pitch += degrees;

        //Check bounds for the camera pitch
        if (camera_pitch > 360.0) {
            camera_pitch -= 360.0;
        } else if (camera_pitch < -360.0) {
            camera_pitch += 360.0;
        }
    }
    var ChangeHeading = function (degrees) {
        //Check bounds with the max heading rate so that we aren't moving too fast
        if (degrees < -max_heading_rate) {
            degrees = -max_heading_rate;
        } else if (degrees > max_heading_rate) {
            degrees = max_heading_rate;
        }
        //This controls how the heading is changed if the camera is pointed straight up or down
        //The heading delta direction changes
        if (camera_pitch > 90 && camera_pitch < 270 || (camera_pitch < -90 && camera_pitch > -270)) {
            camera_heading -= degrees;
        } else {
            camera_heading += degrees;
        }
        //Check bounds for the camera heading
        if (camera_heading > 360.0) {
            camera_heading -= 360.0;
        } else if (camera_heading < -360.0) {
            camera_heading += 360.0;
        }

    }

    var moveCamera = function (move) {
        if (scope.enabled === false) return;
        var t = new THREE.Vector3(0, 0, 0);
        switch (move) {
        case MOVE.UP:
            t.copy(camera_up);
            t.multiplyScalar(camera_scale);
            camera_position_delta.add(t);
            break;
        case MOVE.DOWN:
            t.copy(camera_up);
            t.multiplyScalar(camera_scale);
            camera_position_delta.sub(t);
            break;
        case MOVE.LEFT:
            t.crossVectors(camera_direction, camera_up);
            t.multiplyScalar(camera_scale);
            camera_position_delta.sub(t);
            break;
        case MOVE.RIGHT:
            t.crossVectors(camera_direction, camera_up);
            t.multiplyScalar(camera_scale);
            camera_position_delta.add(t);
            break;
        case MOVE.FORWARD:
            t.copy(camera_direction);
            t.multiplyScalar(camera_scale);
            camera_position_delta.add(t);
            break;
        case MOVE.BACK:
            t.copy(camera_direction);
            t.multiplyScalar(camera_scale);
            camera_position_delta.sub(t);
            break;
        }
    }
    var onKeyDown = function (event) {

        switch (event.keyCode) {
        case 81: //q
        case 33: //PgUp
            moveCamera(MOVE.DOWN);
            break;
        case 69: // e
        case 34: // PgDown
            moveCamera(MOVE.UP);
            break;
        case 38: // up
        case 87: // w
            moveCamera(MOVE.FORWARD);
            break;
        case 37: // left
        case 65: // a
            moveCamera(MOVE.LEFT);
            break;
        case 40: // down
        case 83: // s
            moveCamera(MOVE.BACK);
            break;
        case 39: // right
        case 68: // d
            moveCamera(MOVE.RIGHT);
            break;
        }

    };

    document.addEventListener('mousemove', onMouseMove, false);
    document.addEventListener('mousedown', onMouseDown, false);
    document.addEventListener('mouseup', onMouseUp, false);
    document.addEventListener('keydown', onKeyDown, false);

    this.enabled = false;

    this.getObject = function () {
        return camera;
    };

    this.isOnObject = function (boolean) {
        isOnObject = boolean;
        canJump = boolean;

    };

    this.getDirection = function () {
        // assumes the camera itself is not rotated
        return camera_direction;
    }();

    this.getLookAt = function (delta) {
        return camera_look_at;
    };

    this.update = function (delta) {
        var axis = new THREE.Vector3(0, 0, 0);
        //console.log(camera_direction);
        camera_direction.subVectors(camera_look_at, camera_position);
        camera_direction.normalize();
        axis.crossVectors(camera_direction, camera_up);
        var pitch_quat = new THREE.Quaternion(0, 0, 0, 1);
        var heading_quat = new THREE.Quaternion(0, 0, 0, 1);
        var temp = new THREE.Quaternion(0, 0, 0, 1);
        pitch_quat.setFromAxisAngle(axis, camera_pitch * Math.PI / 180.0);
        heading_quat.setFromAxisAngle(camera_up, camera_heading * Math.PI / 180.0);
        temp.multiplyQuaternions(pitch_quat, heading_quat);
        camera_direction.applyQuaternion(temp);
        camera_position.add(camera_position_delta);
        camera_look_at.addVectors(camera_position, camera_direction);

        camera.position.copy(camera_position);
        camera.up.copy(camera_up);
        camera.lookAt(camera_look_at);
        if (move_camera == false) {
            camera_pitch = camera_pitch * .5;
            camera_heading = camera_heading * .5;
        }
        camera_position_delta.multiplyScalar(.8);
    };
};
</pre>
