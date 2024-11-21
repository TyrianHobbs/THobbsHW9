module Geometry

    import Base.show, Base.:(==)
    import Makie: plottype, Lines, convert_arguments

    export Point2D, Point3D, Polygon, distance, perimeter, isRectangular, area

    """
            Point2D(x::Real, y::Real)
            Point2D(s::str)

    Creates a two-dimensional point with coordinates x and y. Can take two real numbers,
    or a string of the form "(x, y)".

    The string constructor can handle integers and decimals, but not other types (like rationals.)

    ### Example
```julia-repl
julia> Point2D(1, 2)
(1, 2)
```

```julia-repl
julia> Point2D("(1, 2)")
(1, 2)
```
    """
    struct Point2D
        x::Real
        y::Real

        Point2D(x::Real, y::Real) = new(x, y)

        function Point2D(str::AbstractString) #Abstract so we can also use substrings! 
            local p = match(r"\((.+)\s*,\s*(.+)\)", str)
            p != nothing || throw(ArgumentError("A string point must be in the form \"(x, y)\""))
            Point2D(parseIntOrDec(p[1]), parseIntOrDec(p[2]))
        end
    end

    Base.show(io::IO, p::Point2D) = print(io, "($(p.x), $(p.y))")
    Base.:(==)(p::Point2D, q::Point2D) = isequal(p.x, q.x) && isequal(p.y, q.y)

    """
            Point3D(x::Real, y::Real, z::Real)

    Creates a three-dimensional point with coordinates x, y, and z.

    ### Example
```julia-repl
julia> Point3D(1, 2, 3)
(1, 2, 3)
```
    """
    struct Point3D
        x::Real
        y::Real
        z::Real
    end

    Base.show(io::IO, p::Point3D) = print(io, "($(p.x), $(p.y), $(p.z))")
    Base.:(==)(p::Point3D, q::Point3D) = p.x == q.x && p.y == q.y && p.z == q.z

    """
            Polygon(points::Vector{Point2D})
            Polygon(nums::Vector{Real})
            Polygon(nums::Real...)

    Create a polygon (Vector of two-dimensional points). 
    The argument may be either a Vector of Point2Ds, a Vector of Reals, any number of Reals, or a string of semicolon-separated points.
    There must be at least three points, and if using Reals, an even number of reals to be converted into points.
    The string constructor can only handle integers and decimals.

    ### Examples
```julia-repl
julia> Polygon([Point2D(0,0), Point2D(1,0), Point2D(0,1)])
[(0, 0), (1, 0), (0, 1)]

julia> Polygon([0, 1, 2, 3, 4, 5])])
[(0, 1), (2, 3), (4, 5)]

julia> Polygon(0, 0.5, pi, 3//7, sqrt(2), -6, 19, -4/3)
[(0, 0.5), (π, 3//7), (1.4142135623730951, -6), (19, -1.3333333333333333)]

julia> Polygon("(0, 0); (1, 0); (0, 1)")
[(0, 0), (1, 0), (0, 1)]
```
    """
    struct Polygon
        points::Vector{Point2D}

        function Polygon(points::Vector{Point2D})
            length(points) >= 3 || throw(ArgumentError("A polygon must have at least 3 points."))
            new(points)
        end

        function Polygon(nums::Vector{T}) where {T <: Real}
            length(nums)%2 == 0 || throw(ArgumentError("There must be an even number of inputs."))
            local p = Vector{Point2D}()
            for i = 1:2:length(nums)
                push!(p, Point2D(nums[i], nums[i+1]))
            end
            Polygon(p)
        end

        function Polygon(nums::Real...)
            points = [p for p in nums]
            Polygon(points)
        end

        function Polygon(str::String)
            q = [Point2D(p) for p in split(str, r"\s*;\s*")]
            Polygon(q)
        end
    end

    Base.show(io::IO,p::Polygon) = print(io, string("[",join(p.points,", "),"]"))
    function Base.:(==)(p::Polygon, q::Polygon)
        length(p.points) == length(q.points) || return false
        for i = 1:length(p.points)
            p.points[i] == q.points[i] || return false
        end
        return true
    end

    """
            distance(a::Point2D, b::Point2D)
            distance(a::Point3D, b::Point3D)

    Calculates the Euclidean distance between two points.
    """
    function distance(a::Point2D, b::Point2D)
        sqrt((b.x-a.x)^2+(b.y-a.y)^2)
    end
    function distance(a::Point3D, b::Point3D)
        sqrt((b.x-a.x)^2+(b.y-a.y)^2+(b.z-a.z)^2)
    end

    """
            perimeter(p::Polygon)

    Calculates the perimeter of a polygon by adding together all the distances between pairs of points.
    """
    function perimeter(p::Polygon)
        local s = 0
        for i = 1:length(p.points)-1
            s += distance(p.points[i], p.points[i+1])
        end
        s+= distance(p.points[length(p.points)], p.points[1])
        return s;
    end

    """
            isRectangular(p::Polygon)

    Checks whether a polygon is rectangular by comparing the distance between opposite corners.
    Returns true when the distance between opposite corners is approximately equal and false otherwise, 
    or if the polygon doesn't have exactly four points.

    """
    function isRectangular(p::Polygon)
        length(p.points) == 4 ? isapprox(distance(p.points[1], p.points[3]), distance(p.points[2], p.points[4])) : false 
    end

    """
            area(p::Polygon)

    Calculates the area of a polygon using the Shoelace formula.
    """
    function area(p::Polygon)
        local s = 0
        for i = 1:length(p.points) - 1
            s += p.points[i].x * p.points[i+1].y - p.points[i].y * p.points[i+1].x
        end
        s += p.points[length(p.points)].x * p.points[1].y - p.points[length(p.points)].y * p.points[1].x
        return .5*abs(s)
    end

    plottype(::Polygon) = Lines
    function convert_arguments(S::Type{<:Lines}, poly::Polygon)
        xpts = [p.x for p in poly.points]
        ypts = [p.y for p in poly.points]
        push!(xpts, poly.points[1].x)
        push!(ypts, poly.points[1].y)
        convert_arguments(S, xpts, ypts)
    end


    function parseIntOrDec(str::AbstractString) #AbstractString allows this to work with substrings.
        m = match(r"^([+-]?\d*)?(\.\d+)?", str) 
        m == nothing && throw(ArgumentError("The string: $str is not an integer or decimal number"))
        m[2] != nothing ? parse(Float64, "$(m[1])$(m[2])") : parse(Int, m[1])
    end


end #module Geometry