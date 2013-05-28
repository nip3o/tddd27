angular.module('economeep').controller 'PaymentsController',
($dialog, $scope, $rootScope, $templateCache, Category, Budget, BudgetEntry, Payment, User, $http) ->
    $scope.categories = []
    $scope.statsByURL = []

    addMonths = (date, months) ->
        date.setMonth(date.getMonth() + months)
        return date

    sameMonth = (d1, d2) ->
        d1.getMonth() == d2.getMonth() and d1.getYear() == d2.getYear()

    getDataForDateMonth = (date) ->
        # Fetch Payments and Categories for the same date's month
        Payment.byDate(date).then (payments) ->
            $scope.payments = payments

        Category.byDate(date).then (stats) ->
            $scope.stats = stats

            # Fetch or create a Budget for a date and add the Budget to scope
            Budget.byDate(date).then(
                (budget) ->
                    for e in budget.budget_entries
                        e.category = $scope.statsByURL[e.category]
                    $scope.budget = budget
                ,
                (error) ->
                    $scope.budget = new Budget(month_start_date: date, budget_entries: [])
                    $scope.budget.$save().then(
                        (budget) ->
                            for e in budget.budget_entries
                                e.category = $scope.statsByURL[e.category]
                            $scope.budget = budget
                    )
            )

    # Transform the categories into Highcharts-readable format
    updateChartData = (newCategories, oldCategories) ->
        if newCategories != oldCategories
            chartData = []
            for c in newCategories
                chartData.push([c.name, c.payment_sum])
            $scope.paymentsChartData = chartData

    # Update chart data when categories change
    $scope.$watch('stats', updateChartData, true)

    updateStatsByURL = (newStats, oldStats) ->
        if oldStats
            # Make sure any old data is flushed out
            for s in oldStats
                $scope.statsByURL[s.url].payment_sum = 0

        if newStats
            # Update the array holding the current stats
            for s in newStats
                $scope.statsByURL[s.url] = s

    $scope.$watch('stats', updateStatsByURL, true)


    # Get the logged-in user
    User.getCurrent().then(
        (user) ->
            $scope.logged_in = true
            $scope.user = user

            Category.query().then (categories) ->
                $scope.categories = categories

            currentDate = new Date()
            getDataForDateMonth(currentDate)
        ,
        (error) ->
            $scope.logged_in = false
    )

    $scope.logOut = ->
        $scope.user.logOut().then(
            (response) ->
                console.log "Logged out"
                $scope.logged_in = false
        )

    $scope.previousMonth = ->
        prevMonthDate = addMonths($scope.budget.month_start_date, -1)
        getDataForDateMonth(prevMonthDate)


    $scope.nextMonth = ->
        nextMonthDate = addMonths($scope.budget.month_start_date, 1)
        getDataForDateMonth(nextMonthDate)


    $scope.addBudgetEntry = ->
        d = $dialog.dialog()

        $rootScope.dialog = d
        $rootScope.categories = $scope.categories
        $rootScope.entry = new BudgetEntry(budget: $scope.budget.url,
                                           amount: '')

        d.open('addBudgetEntryForm', 'AddBudgetEntryController').then(
            (entry)->
                $scope.budget.budget_entries.push(entry)
        )


    $scope.addPayment = ->
        d = $dialog.dialog()

        $rootScope.dialog = d
        $rootScope.categories = $scope.categories

        d.open('addPaymentForm', 'AddPaymentController').then(
            (payment)->
                paymentDate = new Date(payment.date)

                if payment and sameMonth(paymentDate,
                                         $scope.budget.month_start_date)
                    category = $scope.statsByURL[payment.category]
                    category.payment_sum += parseFloat(payment.amount)
                    payment.category = category
                    $scope.payments.push(payment)
        )

    $scope.addCategory = ->
        d = $dialog.dialog()

        $rootScope.dialog = d

        d.open('addCategoryForm', 'AddCategoryController').then(
            (category)->
                $scope.categories.push(category)
        )


angular.module('economeep').controller 'AddPaymentController', ($scope, $rootScope, Payment) ->
    $scope.payment = new Payment({description: '', amount: ''})

    $scope.save = ->
        $scope.payment.$save().then(
            (payment)->
                $rootScope.dialog.close(payment)

        )

    $scope.cancel = -> $rootScope.dialog.close()


angular.module('economeep').controller 'AddCategoryController', ($scope, $rootScope, Category) ->
    $scope.category = new Category({name: ''})

    $scope.save = ->
        $scope.category.$save().then(
            (category)->
                $rootScope.dialog.close(category)
        )

    $scope.cancel = -> $rootScope.dialog.close()


angular.module('economeep').controller 'AddBudgetEntryController', ($scope, $rootScope, Budget, Category) ->
    $scope.entry = $rootScope.entry

    $scope.save = ->
        $scope.entry.$save().then(
            (entry) ->
                # Replace the selected category URL with a new, fresh
                # category object for that URL from server
                category = Category.get(entry.category).then(
                    (category) ->
                        entry.category = category
                        $rootScope.dialog.close(entry)
                )

        )

    $scope.cancel = -> $rootScope.dialog.close()
