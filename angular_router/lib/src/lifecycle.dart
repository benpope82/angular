// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'router/router_state.dart';

// Interfaces that can be implemented/extended/mixed-in in order to inform
// behavior of the router. It's assumed that all of these interfaces are applied
// directly on `@Component` annotated classes that are created by a router
// outlet during SPA (single-page application) navigation.

/// A lifecycle interface that allows conditionally activating a new route.
///
/// Component classes should `implement` this if they will be navigated to as
/// part of a route definition and would like to determine if the route should
/// be allowed.
///
/// Some example uses could include only allowing logged in users access to a
/// "profile editor" component (not as a security measure) or to record what
/// the previous route is for analytics before navigating.
abstract class CanActivate {
  /// Called by the router when a transition is requested from router states.
  ///
  /// The client should return a future that completes with `true` in order to
  /// accept the transition, or completes with `false` in order to reject it
  /// (and prevent the routing from occurring).
  ///
  /// You can use `async` in order to simplify when returning synchronously:
  ///
  /// ```
  /// class MyComponent implements CanActivate {
  ///   @override
  ///   Future<bool> canActivate(RouterState _, RouterState __) async {
  ///     // Maybe this page isn't ready yet for production, so always reject.
  ///     return false;
  ///   }
  /// }
  /// ```
  ///
  /// This lifecycle occurs *after* `CanDeactivate.canDeactivate`.
  Future<bool> canActivate(RouterState current, RouterState next) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return true;
  }
}

/// A lifecycle interface that allows conditionally deactivating a route.
///
/// Component classes should `implement` this if they will be navigated to as
/// part of a route definition and would like to determine if routing away
/// should be allowed.
///
/// Some example uses could include preventing navigation when a user hasn't
/// saved an incomplete form or to record what the new route is for analytics
/// before navigating.
abstract class CanDeactivate {
  /// Called by the router when a transition is requested from router states.
  ///
  /// The client should return a future that completes with `true` in order to
  /// accept the transition, or completes with `false` in order to reject it
  /// (and prevent the routing from occurring).
  ///
  /// You can use `async` in order to simplify when returning synchronously:
  ///
  /// ```
  /// class MyComponent implements CanDeactivate {
  ///   bool get hasFormBeenSaved => ...
  ///
  ///   @override
  ///   Future<bool> canDeactivate(RouterState _, RouterState __) async {
  ///     return hasFormBeenSaved;
  ///   }
  /// }
  /// ```
  ///
  /// This lifecycle occurs *before* `CanActivate.canActivate`.
  Future<bool> canDeactivate(RouterState current, RouterState next) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return true;
  }
}

/// A lifecycle interface that allows re-using an existing component instance.
///
/// Component classes should `implement` this if they will be navigated to as
/// part of a route definition and would like to determine whether a minor
/// change to the route (such as a route parameter changing) should invalidate
/// the component entirely or not.
abstract class CanReuse {
  /// Called by the router if the new route still uses this component, and the
  /// component class can notify the router if re-using the existing instance is
  /// possible.
  ///
  /// If this interface is _not_ implemented, the component is always destroyed
  /// and re-created; otherwise the client should return a future that completes
  /// with `true` in order to re-use this instance of the component, or
  /// completes with `false` in order to destroy and re-create a new instance.
  ///
  /// You can use `async` in order to simplify when returning synchronously:
  ///
  /// ```
  /// class MyComponent implements CanReuse {
  ///   @override
  ///   Future<bool> canReuse(RouterState current, RouterState next) async {
  ///     // Always re-use this instance.
  ///     return true;
  ///   }
  /// }
  /// ```
  ///
  /// Or simply mixin or extend this class:
  ///
  /// ```
  /// class MyComponent extends CanReuse {}
  /// ```
  Future<bool> canReuse(RouterState current, RouterState next) async {
    // Provided as a default if someone extends or mixes-in this interface.
    return true;
  }
}

/// A lifecycle interface to notify when a component is created by a route.
///
/// Component classes should `implement` this if they will be navigated to as
/// part of a route definition and would like to be notified if they were
/// created due to routing.
abstract class OnActivate {
  /// Called after component is inserted by a router outlet.
  ///
  /// This will occur *after* initial change detection.
  ///
  /// **NOTE**: If [CanReuse] is implemented and re-use is done, this will also
  /// be called when the transition keeps this component, even though the same
  /// component instance was used:
  ///
  /// ```dart
  /// class MyComponent extends CanReuse implements OnActivate {
  ///   User user;
  ///
  ///   @override
  ///   void onActivate(_, RouterState current) {
  ///     var userId = current.getParameter('userId');
  ///     getUserById(userId).then((user) => this.user = user);
  ///   }
  /// }
  /// ```
  void onActivate(RouterState previous, RouterState current);
}

/// A lifecycle interface to notify when a component is destroyed by a route.
///
/// Component classes should `implement` this if they will be navigated to as
/// part of a route definition and would like to be notified if they are being
/// destroyed due to routing.
abstract class OnDeactivate {
  /// Called before component destruction when routing destroyed this component.
  ///
  /// **NOTE**: If [CanReuse] is implemented and re-use is done, this will not
  /// be called when the transition keeps this component; see [OnReuse] instead.
  void onDeactivate(RouterState previous, RouterState current);
}
