var RootCtrl,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('insights.app.real.teams', ['ui.bootstrap', 'rui.tree', 'rally.app', 'rally.api.wsapi', 'sdpi.api.services.metrics', 'insights.app.real.teams.tree']).config(function($slmProvider, $sdpiProvider) {
  $slmProvider.setBaseUrl('//rally1.rallydev.com/slm/');
  return $sdpiProvider.setBaseUrl('//rally1.rallydev.com/insight/');
}).run(function($rally, $rootScope) {
  if ($rootScope.app == null) {
    $rootScope.app = {};
  }
  return $rally.launchApp('insights.app.real.teams').then(function(app) {
    return _.merge($rootScope.app, app.getContext().map.map);
  });
}).constant('metricsToLoad', ['RealTeam', 'FullTimeEquivalent', 'TeamGrowth', 'TeamShrinkage', 'TeamStability', 'PercentDedicatedWork', 'DedicatedTeamSize', 'InProgressStoryCount', 'WorkInProgress', 'WorkInProgressPerFullTimeEquivalent']).controller('RootCtrl', RootCtrl = (function() {
  function RootCtrl($scope, $wsapi, $sdpi, metricsToLoad) {
    var _base;
    this.$scope = $scope;
    this.$wsapi = $wsapi;
    this.$sdpi = $sdpi;
    this.metricsToLoad = metricsToLoad;
    this.loadMetrics = __bind(this.loadMetrics, this);
    this.watchProjectScope = __bind(this.watchProjectScope, this);
    if ((_base = this.$scope).state == null) {
      _base.state = {
        startOn: moment().subtract('months', 1).format('YYYY-MM'),
        endBefore: moment().format('YYYY-MM')
      };
    }
    this.$scope.$watchCollection('[app.project, app.workspace]', this.watchProjectScope);
  }

  RootCtrl.prototype.watchProjectScope = function(_arg) {
    var project, projectScope, workspace;
    project = _arg[0], workspace = _arg[1];
    if (!((project != null) || (workspace != null))) {
      return;
    }
    this.$scope.state.projectScope = projectScope = project;
    project.oid = project.ObjectID;
    project.workspaceOid = workspace.ObjectID;
    this.$scope.state.projectPromise = this.$wsapi.projects.scope(projectScope, 'down').then(function() {}, function() {}, (function(_this) {
      return function(projectScope) {
        return _this.loadMetrics(projectScope);
      };
    })(this))["finally"]((function(_this) {
      return function() {
        return _this.$scope.state.projectPromise.$finished = true;
      };
    })(this));
    this.$scope.state.projectPromise.$finished = false;
    this.$scope.state.nodes = [projectScope];
    return this.$scope.state.selectedNode = projectScope;
  };

  RootCtrl.prototype.loadMetrics = function(projectScope) {
    projectScope.$metricsPromise = this.$sdpi.metrics.data({
      projects: projectScope.oid,
      workspaces: projectScope.workspaceOid,
      'start-date': this.$scope.state.startOn,
      'end-date': this.$scope.state.endBefore,
      granularity: 'month',
      metrics: this.metricsToLoad.join(','),
      'jsonp': 'JSON_CALLBACK'
    }, {
      method: 'JSONP'
    }).then((function(_this) {
      return function(result) {
        var dataPoint, scope, timePeriod;
        timePeriod = {
          month: _this.$scope.state.startOn
        };
        scope = _.find(result.data.scopes, {
          oid: "" + projectScope.oid
        });
        if (scope == null) {
          return null;
        }
        dataPoint = _.find(scope != null ? scope.dataPoints : void 0, timePeriod);
        return dataPoint;
      };
    })(this)).then(function(dataPoint) {
      return projectScope.metrics = dataPoint != null ? dataPoint.data : void 0;
    })["finally"](function() {
      return projectScope.$metricsPromise.$finished = true;
    });
    return projectScope.$metricsPromise.$finished = false;
  };

  return RootCtrl;

})());

angular.module('insights.app.real.teams.tree', ['rui.tree']).directive('ruiTreeNodeContent', function() {
  return {
    compile: function($element, $attrs) {
      $element.append('<span ng-if="!$ruiTreeNode.node.$metricsPromise.$finished" class="icon-progress icon-spin"></span>\n<span ng-if="$ruiTreeNode.node.$metricsPromise.$finished">\n	<span class="icon-shared" \n		ng-if="$ruiTreeNode.node.metrics.RealTeam.value", \n		tooltip="Identified as a Real Team with FTE {{$ruiTreeNode.node.metrics.FullTimeEquivalent.value | number:2 }}", \n		tooltip-placement="right"\n		tooltip-append-to-body="true"\n		></span>\n</span>');
      return function() {};
    }
  };
});
