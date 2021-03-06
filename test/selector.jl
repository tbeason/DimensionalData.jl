using DimensionalData, Test, Unitful, Combinatorics
using DimensionalData: Forward, Reverse, Ordered,
      arrayorder, indexorder, relationorder, between, at, near, contains

a = [1 2  3  4
     5 6  7  8
     9 10 11 12]

@testset "selector primitives" begin

    @testset "Regular Intervals IndexMode with range" begin
        # Order: index, array, relation (array order is irrelevent here, it's just for plotting)
        startfwdfwd = Ti(5.0:30.0;      mode=Sampled(Ordered(Forward(),Forward(),Forward()), Regular(1), Intervals(Start())))
        startfwdrev = Ti(5.0:30.0;      mode=Sampled(Ordered(Forward(),Forward(),Reverse()), Regular(1), Intervals(Start())))
        startrevfwd = Ti(30.0:-1.0:5.0; mode=Sampled(Ordered(Reverse(),Forward(),Forward()), Regular(-1), Intervals(Start())))
        startrevrev = Ti(30.0:-1.0:5.0; mode=Sampled(Ordered(Reverse(),Forward(),Reverse()), Regular(-1), Intervals(Start())))

        @testset "Any at" begin
            @test at(startfwdfwd, At(30)) == 26
            @test at(startrevfwd, At(30)) == 1
            @test at(startfwdrev, At(30)) == 1
            @test at(startrevrev, At(30)) == 26
        end

        @testset "Start between" begin
            @test between(startfwdfwd, Between(9.9, 15.1)) === 6:10
            @test between(startfwdrev, Between(9.9, 15.1)) === 17:1:21
            @test between(startrevfwd, Between(9.9, 15.1)) === 17:21
            @test between(startrevrev, Between(9.9, 15.1)) === 6:1:10
            @test between(startfwdfwd, Between(10, 15)) === 6:10
            @test between(startfwdrev, Between(10, 15)) === 17:1:21
            @test between(startrevfwd, Between(10, 15)) === 17:21
            @test between(startrevrev, Between(10, 15)) === 6:1:10
            # Input order doesn't matter
            @test between(startfwdfwd, Between(15, 10)) === 6:10
        end

        @testset "Start contains" begin
            @test_throws BoundsError contains(startfwdfwd, Contains(4.9))
            @test_throws BoundsError contains(startfwdfwd, Contains(31))
            @test_throws BoundsError contains(startrevfwd, Contains(4.9))
            @test_throws BoundsError contains(startrevfwd, Contains(31))
            @test contains(startfwdfwd, Contains(5)) == 1
            @test contains(startfwdfwd, Contains(5.9)) == 1
            @test contains(startfwdfwd, Contains(6.0)) == 2
            @test contains(startfwdfwd, Contains(30.0)) == 26
            @test contains(startfwdfwd, Contains(29.9)) == 25
            @test contains(startrevfwd, Contains(5.9)) == 26
            @test contains(startrevfwd, Contains(6.0)) == 25
            @test contains(startrevfwd, Contains(30.9)) == 1
            @test contains(startrevfwd, Contains(30.0)) == 1
            @test contains(startrevfwd, Contains(29.0)) == 2
            @test contains(startfwdrev, Contains(5.9)) == 26
            @test contains(startfwdrev, Contains(6.0)) == 25
            @test contains(startfwdrev, Contains(30.0)) == 1
            @test contains(startfwdrev, Contains(29.9)) == 2
            @test contains(startrevrev, Contains(5.9)) == 1
            @test contains(startrevrev, Contains(6.0)) == 2
            @test contains(startrevrev, Contains(29.9)) == 25
            @test contains(startrevrev, Contains(30.0)) == 26
        end

        @testset "Start near" begin
            @test bounds(startfwdfwd) == bounds(startfwdrev) == bounds(startrevrev) == bounds(startrevfwd)
            @test near(startfwdfwd, Near(50)) == 26
            @test near(startfwdfwd, Near(0)) == 1
            @test near(startfwdfwd, Near(5.9)) == 1
            @test near(startfwdfwd, Near(6.0)) == 2
            @test near(startfwdfwd, Near(30.0)) == 26
            @test near(startfwdfwd, Near(29.9)) == 25
            @test near(startfwdrev, Near(5.9)) == 26
            @test near(startfwdrev, Near(6.0)) == 25
            @test near(startfwdrev, Near(29.9)) == 2
            @test near(startfwdrev, Near(30.0)) == 1
            @test near(startrevfwd, Near(5.9)) == 26
            @test near(startrevfwd, Near(6.0)) == 25
            @test near(startrevfwd, Near(29.0)) == 2
            @test near(startrevfwd, Near(30.0)) == 1
            @test near(startrevrev, Near(5.9)) == 1
            @test near(startrevrev, Near(6.0)) == 2
            @test near(startrevrev, Near(29.9)) == 25
            @test near(startrevrev, Near(30.0)) == 26
        end

        centerfwdfwd = Ti((5.0:30.0);      mode=Sampled(Ordered(Forward(),Forward(),Forward()), Regular(1), Intervals(Center())))
        centerfwdrev = Ti((5.0:30.0);      mode=Sampled(Ordered(Forward(),Forward(),Reverse()), Regular(1), Intervals(Center())))
        centerrevfwd = Ti((30.0:-1.0:5.0); mode=Sampled(Ordered(Reverse(),Forward(),Forward()), Regular(-1), Intervals(Center())))
        centerrevrev = Ti((30.0:-1.0:5.0); mode=Sampled(Ordered(Reverse(),Forward(),Reverse()), Regular(-1), Intervals(Center())))

        @testset "Center between" begin
            @test between(centerfwdfwd, Between(9.9, 15.1)) === 7:10
            @test between(centerfwdrev, Between(9.9, 15.1)) === 17:1:20
            @test between(centerrevfwd, Between(9.9, 15.1)) === 17:20
            @test between(centerrevrev, Between(9.9, 15.1)) === 7:1:10
            @test between(centerfwdfwd, Between(10, 15)) === 7:10
            @test between(centerfwdrev, Between(10, 15)) === 17:1:20
            @test between(centerrevfwd, Between(10, 15)) === 17:20
            @test between(centerrevrev, Between(10, 15)) === 7:1:10
            # Input order doesn't matter
            @test between(centerfwdfwd, Between(15, 10)) === 7:10
        end

        @testset "Center contains" begin
            @test_throws BoundsError contains(centerfwdfwd, Contains(4.4))
            @test_throws BoundsError contains(centerfwdfwd, Contains(30.5))
            @test_throws BoundsError contains(centerrevfwd, Contains(4.4))
            @test_throws BoundsError contains(centerrevfwd, Contains(30.5))
            @test contains(centerfwdfwd, Contains(4.5)) == 1
            @test contains(centerfwdfwd, Contains(30.4)) == 26
            @test contains(centerfwdfwd, Contains(29.5)) == 26
            @test contains(centerfwdfwd, Contains(29.4)) == 25
            @test contains(centerrevfwd, Contains(4.5)) == 26
            @test contains(centerrevfwd, Contains(30.4)) == 1
            @test contains(centerrevfwd, Contains(29.5)) == 1
            @test contains(centerrevfwd, Contains(29.4)) == 2
            @test contains(centerfwdrev, Contains(29.5)) == 1
            @test contains(centerfwdrev, Contains(29.4)) == 2
            @test contains(centerrevrev, Contains(29.5)) == 26
            @test contains(centerrevrev, Contains(29.4)) == 25
        end

        @testset "Center near" begin
            @test near(centerfwdfwd, Near(4.4)) == 1
            @test near(centerfwdfwd, Near(30.5)) == 26
            @test near(centerrevfwd, Near(4.4)) == 26
            @test near(centerrevfwd, Near(30.5)) == 1
            @test near(centerfwdfwd, Near(4.5)) == 1
            @test near(centerfwdfwd, Near(30.4)) == 26
            @test near(centerfwdfwd, Near(29.5)) == 26
            @test near(centerfwdfwd, Near(29.4)) == 25
            @test near(centerrevfwd, Near(4.5)) == 26
            @test near(centerrevfwd, Near(30.4)) == 1
            @test near(centerrevfwd, Near(29.5)) == 1
            @test near(centerrevfwd, Near(29.4)) == 2
            @test near(centerfwdrev, Near(29.5)) == 1
            @test near(centerfwdrev, Near(29.4)) == 2
            @test near(centerrevrev, Near(29.5)) == 26
            @test near(centerrevrev, Near(29.4)) == 25
        end

        endfwdfwd = Ti((5.0:30.0);      mode=Sampled(Ordered(Forward(),Forward(),Forward()), Regular(1), Intervals(End())))
        endfwdrev = Ti((5.0:30.0);      mode=Sampled(Ordered(Forward(),Forward(),Reverse()), Regular(1), Intervals(End())))
        endrevfwd = Ti((30.0:-1.0:5.0); mode=Sampled(Ordered(Reverse(),Forward(),Forward()), Regular(-1), Intervals(End())))
        endrevrev = Ti((30.0:-1.0:5.0); mode=Sampled(Ordered(Reverse(),Forward(),Reverse()), Regular(-1), Intervals(End())))

        @testset "End between" begin
            @test between(endfwdfwd, Between(9.9, 15.1)) === 7:11
            @test between(endfwdrev, Between(9.9, 15.1)) === 16:1:20
            @test between(endrevfwd, Between(9.9, 15.1)) === 16:20
            @test between(endrevrev, Between(9.9, 15.1)) === 7:1:11
            @test between(endfwdfwd, Between(10, 15)) === 7:11
            @test between(endfwdrev, Between(10, 15)) === 16:1:20
            @test between(endrevfwd, Between(10, 15)) === 16:20
            @test between(endrevrev, Between(10, 15)) === 7:1:11
            # Input order doesn't matter
            @test between(endfwdfwd, Between(15, 10)) === 7:11
        end

        @testset "End contains" begin
            @test_throws BoundsError contains(endfwdfwd, Contains(4))
            @test_throws BoundsError contains(endfwdfwd, Contains(30.1))
            @test_throws BoundsError contains(endrevfwd, Contains(4))
            @test_throws BoundsError contains(endrevfwd, Contains(30.1))
            @test contains(endfwdfwd, Contains(4.1)) == 1
            @test contains(endfwdfwd, Contains(5.0)) == 1
            @test contains(endfwdfwd, Contains(5.1)) == 2
            @test contains(endfwdfwd, Contains(29.0)) == 25
            @test contains(endfwdfwd, Contains(29.1)) == 26
            @test contains(endfwdfwd, Contains(30.0)) == 26
            @test contains(endrevfwd, Contains(4.1)) == 26
            @test contains(endrevfwd, Contains(5.0)) == 26
            @test contains(endrevfwd, Contains(5.1)) == 25
            @test contains(endrevfwd, Contains(29.0)) == 2
            @test contains(endrevfwd, Contains(29.1)) == 1
            @test contains(endrevfwd, Contains(30.0)) == 1
            @test contains(endrevrev, Contains(5.0)) == 1
            @test contains(endrevrev, Contains(5.1)) == 2
            @test contains(endrevrev, Contains(29.0)) == 25
            @test contains(endrevrev, Contains(29.1)) == 26
            @test contains(endrevfwd, Contains(5.0)) == 26
            @test contains(endrevfwd, Contains(5.1)) == 25
            @test contains(endrevfwd, Contains(29.0)) == 2
            @test contains(endrevfwd, Contains(29.1)) == 1
        end

        @testset "End near" begin
            @test near(endfwdfwd, Near(4)) == 1
            @test near(endfwdfwd, Near(5.0)) == 1
            @test near(endfwdfwd, Near(5.1)) == 2
            @test near(endfwdfwd, Near(29.0)) == 25
            @test near(endfwdfwd, Near(29.1)) == 26
            @test near(endfwdfwd, Near(30.0)) == 26
            @test near(endfwdfwd, Near(31.1)) == 26
            @test near(endrevfwd, Near(4)) == 26
            @test near(endrevfwd, Near(5.0)) == 26
            @test near(endrevfwd, Near(5.1)) == 25
            @test near(endrevfwd, Near(29.0)) == 2
            @test near(endrevfwd, Near(29.1)) == 1
            @test near(endrevfwd, Near(30.0)) == 1
            @test near(endrevfwd, Near(31.1)) == 1
            @test near(endrevrev, Near(5.0)) == 1
            @test near(endrevrev, Near(5.1)) == 2
            @test near(endrevrev, Near(29.0)) == 25
            @test near(endrevrev, Near(29.1)) == 26
            @test near(endrevfwd, Near(5.0)) == 26
            @test near(endrevfwd, Near(5.1)) == 25
            @test near(endrevfwd, Near(29.0)) == 2
            @test near(endrevfwd, Near(29.1)) == 1
        end

    end
    @testset "RegulaSpan Intervals mode with array" begin
        # Order: index, array, relation (array order is irrelevent here, it's just for plotting)
        startfwd = Ti([1, 3, 4, 5]; mode=Sampled(Ordered(index=Forward()), Regular(1), Intervals(Start())))
        startrev = Ti([5, 4, 3, 1]; mode=Sampled(Ordered(index=Reverse()), Regular(-1), Intervals(Start())))

        @test_throws BoundsError contains(startfwd, Contains(0.9))
        @test contains(startfwd, Contains(1.0)) == 1
        @test contains(startfwd, Contains(1.9)) == 1
        @test_throws ErrorException contains(startfwd, Contains(2))
        @test_throws ErrorException contains(startfwd, Contains(2.9))
        @test contains(startfwd, Contains(3)) == 2
        @test contains(startfwd, Contains(5.9)) == 4
        @test_throws BoundsError contains(startfwd, Contains(6))

        @test_throws BoundsError contains(startrev, Contains(0.9))
        @test contains(DimensionalData.mode(startrev), startrev, Contains(1.0)) == 4
        @test contains(DimensionalData.mode(startrev), startrev, Contains(1.9)) == 4
        @test_throws ErrorException contains(startrev, Contains(2))
        @test_throws ErrorException contains(startrev, Contains(2.9))
        @test contains(startrev, Contains(3)) == 3
        @test contains(startrev, Contains(5.9)) == 1
        @test_throws BoundsError contains(startrev, Contains(6))

    end


    @testset "Points mode" begin

        fwdfwd = Ti((5.0:30.0);      mode=Sampled(order=Ordered(Forward(),Forward(),Forward())))
        fwdrev = Ti((5.0:30.0);      mode=Sampled(order=Ordered(Forward(),Forward(),Reverse())))
        revfwd = Ti((30.0:-1.0:5.0); mode=Sampled(order=Ordered(Reverse(),Forward(),Forward())))
        revrev = Ti((30.0:-1.0:5.0); mode=Sampled(order=Ordered(Reverse(),Forward(),Reverse())))

        @testset "between" begin
            @test between(fwdfwd, Between(10, 15)) === 6:11
            @test between(fwdrev, Between(10, 15)) === 16:1:21
            @test between(revfwd, Between(10, 15)) === 16:21
            @test between(revrev, Between(10, 15)) === 6:1:11
            # Input order doesn't matter
            @test between(fwdfwd, Between(15, 10)) === 6:11
        end

        @testset "at" begin
            @test at(fwdfwd, At(30)) == 26
            @test at(revfwd, At(30)) == 1
            @test at(fwdrev, At(30)) == 1
            @test at(revrev, At(30)) == 26
        end

        @testset "near" begin
            @test near(fwdfwd, Near(50))   == 26
            @test near(fwdfwd, Near(0))    == 1
            @test near(fwdfwd, Near(29.4)) == 25
            @test near(fwdfwd, Near(29.5)) == 26
            @test near(revfwd, Near(29.4)) == 2
            @test near(revfwd, Near(30.1)) == 1
            @test near(fwdrev, Near(29.4)) == 2
            @test near(fwdrev, Near(29.5)) == 1
            @test near(revrev, Near(29.4)) == 25
            @test near(revrev, Near(30.1)) == 26
        end

    end

end


@testset "Selectors on Sampled" begin
    da = DimensionalArray(a, (Y((10, 30); mode=Sampled()),
                              Ti((1:4)u"s"; mode=Sampled())))

    @test At(10.0) == At(10.0, 0.0, Base.rtoldefault(eltype(10.0)))
    x = [10.0, 20.0]
    @test At(x) === At(x, 0.0, Base.rtoldefault(eltype(10.0)))
    @test At((10.0, 20.0)) === At((10.0, 20.0), 0.0, Base.rtoldefault(eltype(10.0)))

    Near([10, 20])

    @test Between(10, 20) == Between((10, 20))

    @testset "selectors with dim wrappers" begin
        @test da[Y(At([10, 30])), Ti(At([1u"s", 4u"s"]))] == [1 4; 9 12]
        @test_throws ArgumentError da[Y(At([9, 30])), Ti(At([1u"s", 4u"s"]))]
        @test view(da, Y(At(20)), Ti(At((3:4)u"s"))) == [7, 8]
        @test view(da, Y(Near(17)), Ti(Near([1.5u"s", 3.1u"s"]))) == [6, 7]
        @test view(da, Y(Between(9, 21)), Ti(At((3:4)u"s"))) == [3 4; 7 8]
    end

    @testset "selectors without dim wrappers" begin
        @test da[At(20:10:30), At(1u"s")] == [5, 9]
        @test view(da, Between(9, 31), Near((3:4)u"s")) == [3 4; 7 8; 11 12]
        @test view(da, Near(22), At([3.0u"s", 4.0u"s"])) == [7, 8]
        @test view(da, At(20), At((2:3)u"s")) == [6, 7]
        @test view(da, Near(13), Near([1.3u"s", 3.3u"s"])) == [1, 3]
        # Near works with a tuple input
        @test view(da, Near([13]), Near([1.3u"s", 3.3u"s"])) == [1 3]
        @test view(da, Between(11, 20), At((2:3)u"s")) == [6 7]
        # Between also accepts a tuple input
        @test view(da, Between((11, 20)), Between((2u"s", 3u"s"))) == [6 7]
    end

    @testset "mixed selectors and standard" begin
        selectors = [
            (Between(9, 31), Near((3:4)u"s")),
            (Near(22), At([3.0u"s", 4.0u"s"])),
            (At(20), At((2:3)u"s")),
            (Near<|13, Near<|[1.3u"s", 3.3u"s"]),
            (Near<|[13], Near<|[1.3u"s", 3.3u"s"]),
            (Between(11, 20), At((2:3)u"s"))
        ]
        positions =  [
            (1:3, [3, 4]),
            (2, [3, 4]),
            (2, [2, 3]),
            (1, [1, 3]),
            ([1], [1, 3]),
            (2:2, [2, 3])
        ]
        for (selector, pos) in zip(selectors, positions)
            pairs = collect(zip(selector, pos))
            cases = [(i, j) for i in pairs[1], j in pairs[2]]
            for (case1, case2) in combinations(cases, 2)
                @test da[case1...] == da[case2...]
                @test view(da, case1...) == view(da, case2...)
                dac1, dac2 = copy(da), copy(da)
                sample = da[case1...]
                replacement  = sample isa Integer ? 100 : rand(Int, size(sample))
                # Test return value
                @test setindex!(dac1, replacement, case1...) == setindex!(dac2, replacement, case2...)
                # Test mutation
                @test dac1 == dac2
            end
        end
    end

    @testset "single-arity standard index" begin
        indices = [
            1:3,
            [1, 2, 4],
            4:-2:1,
        ]
        for idx in indices
            from2d = da[idx]
            @test from2d == data(da)[idx]
            @test !(from2d isa AbstractDimensionalArray)
            from1d = da[Y <| At(10)][idx]
            @test from1d == data(da)[1, :][idx]
            @test from1d isa AbstractDimensionalArray
        end
    end

    @testset "single-arity views" begin
        indices = [
            3,
            1:3,
            [1, 2, 4],
            4:-2:1,
        ]
        for idx in indices
            from2d = view(da, idx)
            @test from2d == view(data(da), idx)
            @test !(parent(from2d) isa AbstractDimensionalArray)
            from1d = view(da[Y <| At(10)], idx)
            @test from1d == view(data(da)[1, :], idx)
            @test parent(from1d) isa AbstractDimensionalArray
        end
    end

    @testset "single-arity setindex!" begin
        indices = [
            3,
            1:3,
            [1, 2, 4],
            4:-2:1,
        ]
        for idx in indices
            # 2D case
            da2d = copy(da)
            a2d = copy(data(da2d))
            replacement = zero(a2d[idx])
            @test setindex!(da2d, replacement, idx) == setindex!(a2d, replacement, idx)
            @test da2d == a2d
            # 1D array
            da1d = da[Y <| At(10)]
            a1d = copy(data(da1d))
            @test setindex!(da1d, replacement, idx) == setindex!(a1d, replacement, idx)
            @test da1d == a1d
        end
    end

    @testset "more Unitful dims" begin
        dimz = Ti(1.0u"s":1.0u"s":3.0u"s"; mode=Sampled()),
               Y((1u"km", 4u"km"); mode=Sampled())
        db = DimensionalArray(a, dimz)
        @test db[Y<|Between(2u"km", 3.9u"km"), Ti<|At<|3.0u"s"] == [10, 11]
    end

    @testset "selectors work in reverse orders" begin
        a = [1 2  3  4
             5 6  7  8
             9 10 11 12]

        @testset "forward index with reverse relation" begin
            da_ffr = DimensionalArray(a, (Y(10:10:30; mode=Sampled(order=Ordered(Forward(), Forward(), Reverse()))),
                                         Ti((1:1:4)u"s"; mode=Sampled(order=Ordered(Forward(), Forward(), Reverse())))))
            @test indexorder(dims(da_ffr, Ti)) == Forward()
            @test arrayorder(dims(da_ffr, Ti)) == Forward()
            @test relationorder(dims(da_ffr, Ti)) == Reverse()
            @test da_ffr[Y<|At(20), Ti<|At((3.0:4.0)u"s")] == [6, 5]
            @test da_ffr[Y<|At([20, 30]), Ti<|At((3.0:4.0)u"s")] == [6 5; 2 1]
            @test da_ffr[Y<|Near(22), Ti<|Near([3.3u"s", 4.3u"s"])] == [6, 5]
            @test da_ffr[Y<|Near([22, 42]), Ti<|Near([3.3u"s", 4.3u"s"])] == [6 5; 2 1]
            # Between hasn't reverse the index order
            @test da_ffr[Y<|Between(19, 35), Ti<|Between(3.0u"s", 4.0u"s")] == [1 2; 5 6]
        end

        @testset "reverse index with forward relation" begin
            da_rff = DimensionalArray(a, (Y(30:-10:10; mode=Sampled(order=Ordered(Reverse(), Forward(), Forward()))),
                                         Ti((4:-1:1)u"s"; mode=Sampled(order=Ordered(Reverse(), Forward(), Forward())))))
            @test da_rff[Y<|At(20), Ti<|At((3.0:4.0)u"s")] == [6, 5]
            @test da_rff[Y<|At([20, 30]), Ti<|At((3.0:4.0)u"s")] == [6 5; 2 1]
            @test da_rff[Y<|Near(22), Ti<|Near([3.3u"s", 4.3u"s"])] == [6, 5]
            @test da_rff[Y<|Near([22, 42]), Ti<|Near([3.3u"s", 4.3u"s"])] == [6 5; 2 1]
            # Between hasn't reverse the index order
            @test da_rff[Y<|Between(20, 30), Ti<|Between(3.0u"s", 4.0u"s")] == [1 2; 5 6]
        end

        @testset "forward index with forward relation" begin
            da_fff = DimensionalArray(a, (Y(10:10:30; mode=Sampled(order=Ordered(Forward(), Forward(), Forward()))),
                                         Ti((1:4)u"s"; mode=Sampled(order=Ordered(Forward(), Forward(), Forward())))))
            @test da_fff[Y<|At(20), Ti<|At((3.0:4.0)u"s")] == [7, 8]
            @test da_fff[Y<|At([20, 30]), Ti<|At((3.0:4.0)u"s")] == [7 8; 11 12]
            @test da_fff[Y<|Near(22), Ti<|Near([3.3u"s", 4.3u"s"])] == [7, 8]
            @test da_fff[Y<|Near([22, 42]), Ti<|Near([3.3u"s", 4.3u"s"])] == [7 8; 11 12]
            @test da_fff[Y<|Between(20, 30), Ti<|Between(3.0u"s", 4.0u"s")] == [7 8; 11 12]
        end

        @testset "reverse index with reverse relation" begin
            da_rfr = DimensionalArray(a, (Y(30:-10:10; mode=Sampled(order=Ordered(Reverse(), Forward(), Reverse()))),
                                         Ti((4:-1:1)u"s"; mode=Sampled(order=Ordered(Reverse(), Forward(), Reverse())))))
            @test da_rfr[Y<|At(20), Ti<|At((3.0:4.0)u"s")] == [7, 8]
            @test da_rfr[Y<|At([20, 30]), Ti<|At((3.0:4.0)u"s")] == [7 8; 11 12]
            @test da_rfr[Y<|Near(22), Ti<|Near([3.3u"s", 4.3u"s"])] == [7, 8]
            @test da_rfr[Y<|Near([22, 42]), Ti<|Near([3.3u"s", 4.3u"s"])] == [7 8; 11 12]
            @test da_rfr[Y<|Between(20, 30), Ti<|Between(3.0u"s", 4.0u"s")] == [7 8; 11 12]
        end

    end

    @testset "setindex! with selectors" begin
        c = deepcopy(a)
        dc = DimensionalArray(c, (Y((10, 30)), Ti((1:4)u"s")))
        dc[Near(11), At(3u"s")] = 100
        @test c[1, 3] == 100
        dc[Ti<|Near(2.2u"s"), Y<|Between(10, 30)] = [200, 201, 202]
        @test c[1:3, 2] == [200, 201, 202]
    end

end

@testset "Selectors on Sampled and Intervals" begin
    da = DimensionalArray(a, (Y((10, 30); mode=Sampled(sampling=Intervals())),
                              Ti((1:4)u"s"; mode=Sampled(sampling=Intervals()))))

    @testset "selectors with dim wrappers" begin
        @test da[Y(At([10, 30])), Ti(At([1u"s", 4u"s"]))] == [1 4; 9 12]
        @test_throws ArgumentError da[Y(At([9, 30])), Ti(At([1u"s", 4u"s"]))]
        @test view(da, Y(At(20)), Ti(At((3:4)u"s"))) == [7, 8]
        @test view(da, Y(Contains(17)), Ti(Contains([1.9u"s", 3.1u"s"]))) == [5, 7]
        @test view(da, Y(Between(4, 26)), Ti(At((3:4)u"s"))) == [3 4; 7 8]
    end

    @testset "selectors without dim wrappers" begin
        @test da[At(20:10:30), At(1u"s")] == [5, 9]
        @test view(da, Between(4, 36), Near((3:4)u"s")) == [3 4; 7 8; 11 12]
        @test view(da, Near(22), At([3.0u"s", 4.0u"s"])) == [7, 8]
        @test view(da, At(20), At((2:3)u"s")) == [6, 7]
        @test view(da, Near(13), Near([1.3u"s", 3.3u"s"])) == [1, 3]
        @test view(da, Near([13]), Near([1.3u"s", 3.3u"s"])) == [1 3]
        @test view(da, Between(11, 26), At((2:3)u"s")) == [6 7]
        # Between also accepts a tuple input
        @test view(da, Between((11, 26)), Between((2u"s", 4u"s"))) == [6 7]
    end
end


@testset "Selectors on NoIndex" begin
    dimz = Ti(), Y()
    da = DimensionalArray(a, dimz)
    @test da[Ti(At([1, 2])), Y(Contains(2))] == [2, 6]
    @test da[Near(2), Between(2, 4)] == [6, 7, 8]
    @test da[Contains([1, 3]), Near([2, 3, 4])] == [2 3 4; 10 11 12]
end

@testset "Selectors on Categorical" begin
    a = [1 2  3  4
         5 6  7  8
         9 10 11 12]

    dimz = Ti([:one, :two, :three]; mode=Categorical(Ordered())),
        Y([:a, :b, :c, :d]; mode=Categorical(Ordered()))
    da = DimensionalArray(a, dimz)
    @test da[Ti(At([:one, :two])), Y(Contains(:b))] == [2, 6]
    @test da[At(:two), Between(:b, :d)] == [6, 7, 8]
    # Near and contains are just At
    @test da[Contains([:one, :three]), Near([:b, :c, :d])] == [2 3 4; 10 11 12]
   
    dimz = Ti([:one, :two, :three]; mode=Categorical(Unordered())),
        Y([:a, :b, :c, :d]; mode=Categorical(Unordered()))
    da = DimensionalArray(a, dimz)
    @test_throws ArgumentError da[At(:two), Between(:b, :d)] == [6, 7, 8]
end

# @testset "TranformedIndex" begin
#     using CoordinateTransformations

#     m = LinearMap([0.5 0.0; 0.0 0.5])

#     dimz = Dim{:trans1}(m; mode=Transformed(X)),
#            Dim{:trans2}(m, mode=Transformed(Y))

#     @testset "permutedims works on mode dimensions" begin
#         @test permutedims((Y(), X()), dimz) == (X(), Y())
#     end

#     da = DimensionalArray(a, dimz)

#     @testset "Indexing with array dims indexes the array as usual" begin
#         @test da[Dim{:trans1}(3), Dim{:trans2}(1)] == 9
#         # Using selectors works the same as indexing with mode
#         # dims - it applies the transform function.
#         # It's not clear this should be allowed or makes sense,
#         # but it works anyway because the permutation is correct either way.
#         @test da[Dim{:trans1}(At(6)), Dim{:trans2}(At(2))] == 9
#     end

#     @testset "Indexing with mode dims uses the transformation" begin
#         @test da[X(Near(6.1)), Y(Near(8.5))] == 12
#         @test da[X(At(4.0)), Y(At(2.0))] == 5
#         @test_throws InexactError da[X(At(6.1)), Y(At(8))]
#         # Indexing directly with mode dims also just works, but maybe shouldn't?
#         @test da[X(2), Y(2)] == 6
#     end
# end
