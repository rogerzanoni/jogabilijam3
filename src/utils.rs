use ggez::graphics::Point2;

pub fn truncate_vector(p: Point2, min: Point2, max: Point2) -> Point2 {
    let mut trunc = p.clone();

    if trunc.x < min.x {
        trunc.x = min.x;
    } else if trunc.x > max.x {
        trunc.x = max.x;
    }

    if trunc.y < min.y {
        trunc.y = min.y;
    } else if trunc.y > max.y {
        trunc.y = max.y;
    }
    trunc
}

pub fn sum_vectors(p1: Point2, p2: Point2) -> Point2 {
    Point2::new(p1.x + p2.x, p1.y + p2.y)
}

pub fn sub_vectors(p1: Point2, p2: Point2) -> Point2 {
    Point2::new(p1.x - p2.x, p1.y - p2.y)
}

pub fn normalize_vector(p: Point2) -> Point2 {
    let module = (p.x.powi(2) + p.y.powi(2)).sqrt();
    Point2::new(p.x / module, p.y / module)
}

pub fn distance(p1: Point2, p2: Point2) -> f32 {
    ((p1.x - p2.x).powi(2) + (p1.y - p2.y).powi(2)).sqrt()
}
