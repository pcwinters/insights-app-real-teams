angular.module('insights.app.real.teams.tree', [
	'rui.tree'
])
.directive 'ruiTreeNodeContent', ()->
	return {
		compile: ($element, $attrs)->
			$element.append('''
				<span ng-if="!$ruiTreeNode.node.$metricsPromise.$finished" class="icon-progress icon-spin"></span>
				<span ng-if="$ruiTreeNode.node.$metricsPromise.$finished">
					<span class="icon-shared" 
						ng-if="$ruiTreeNode.node.metrics.RealTeam.value", 
						tooltip="Identified as a Real Team with FTE {{$ruiTreeNode.node.metrics.FullTimeEquivalent.value | number:2 }}", 
						tooltip-placement="right"
						tooltip-append-to-body="true"
						></span>
				</span>
			''')

			return ->
	}
