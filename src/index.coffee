angular.module('insights.app.real.teams', [
	'ui.bootstrap'
	'rui.tree'
	'rally.app'
	'rally.api.wsapi'
	'sdpi.api.services.metrics'
	'insights.app.real.teams.tree'
])
.config ($slmProvider, $sdpiProvider)->
	$slmProvider.setBaseUrl( '//rally1.rallydev.com/slm/')
	$sdpiProvider.setBaseUrl('https://test13cluster.rallydev.com/insight/')

.run ($rally, $rootScope)->
	$rootScope.app ?= {};
	$rally.launchApp('insights.app.real.teams').then (app)->
		_.merge($rootScope.app, app.getContext().map.map)
.constant 'metricsToLoad', [
	'RealTeam'
	'FullTimeEquivalent'
	'TeamGrowth'
	'TeamShrinkage'
	'TeamStability'
	'PercentDedicatedWork'
	'DedicatedTeamSize'
	'InProgressStoryCount'
	'WorkInProgress'
	'WorkInProgressPerFullTimeEquivalent'
]
.controller 'RootCtrl',
	class RootCtrl
		constructor: (@$scope, @$wsapi, @$sdpi, @metricsToLoad)->
			@$scope.state ?= 
				startOn: moment().subtract('months', 1).format('YYYY-MM')
				endBefore: moment().format('YYYY-MM')
			@$scope.$watchCollection('[app.project, app.workspace]', @watchProjectScope)

		watchProjectScope: ([project, workspace])=>
			if not (project? or workspace?) then return
			
			# TODO figure out if project/workspace is in scope.
			@$scope.state.projectScope = projectScope = project
			project.oid = project.ObjectID
			project.workspaceOid = workspace.ObjectID

			@$scope.state.projectPromise = @$wsapi.projects.scope(projectScope, 'down').then(
				()->
				()->
				(projectScope)=>
					@loadMetrics(projectScope)
			).finally ()=>
				@$scope.state.projectPromise.$finished = true
			@$scope.state.projectPromise.$finished = false
			@$scope.state.nodes = [projectScope]
			@$scope.state.selectedNode = projectScope

		loadMetrics: (projectScope)=>
			projectScope.$metricsPromise = @$sdpi.metrics.data({
				projects: projectScope.oid
				workspaces: projectScope.workspaceOid
				'start-date': @$scope.state.startOn
				'end-date': @$scope.state.endBefore
				granularity: 'month'
				metrics: @metricsToLoad.join(',')
				'jsonp': 'JSON_CALLBACK'
			}, {method: 'JSONP'})
			.then (result) =>
				timePeriod = {month: @$scope.state.startOn}
				scope = _.find(result.data.scopes, {oid: "#{projectScope.oid}"})
				if not scope? then return null
				dataPoint = _.find(scope?.dataPoints, timePeriod)
				return dataPoint
			.then (dataPoint)->
				projectScope.metrics = dataPoint.data
			.finally ()->
				projectScope.$metricsPromise.$finished = true
			projectScope.$metricsPromise.$finished = false
