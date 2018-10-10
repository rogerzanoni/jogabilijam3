use ggez::graphics::{Color, DrawMode, Mesh, Point2};
use ggez::*;
use utils::*;

pub struct Demonstrator {
    pub position: Point2,
    pub color: Color,
    pub velocity: Point2,
    pub max_velocity: f32,
    pub size: Point2,
    pub shape: Mesh,
}

impl Demonstrator {
    pub fn build_demonstrator(ctx: &mut Context, pos: Point2) -> Demonstrator {
        Demonstrator {
            position: pos,
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.7,
            size: Point2::new(10.0, 10.0),
            color: Color::from_rgb(255, 0, 0),
            shape: Mesh::new_circle(ctx, DrawMode::Fill, Point2::new(0.0, 0.0), 10.0, 0.2).unwrap(),
        }
    }

    pub fn update(&mut self, officers: &Vec<Officer>) {
        let mut closest = &officers[0];
        let closest_distance = distance(self.position, closest.position);

        for officer in officers {
            let distance = distance(self.position, officer.position);
            if distance < closest_distance {
                closest = officer;
            }
        }

        // Seek behaviour
        let desired_velocity =
            normalize_vector(sub_vectors(self.position, closest.position)) * self.max_velocity;
        let steering = desired_velocity - self.velocity;
        self.velocity = self.velocity + steering;

        // Update position
        self.position = sum_vectors(self.position, self.velocity);
        self.position = truncate_vector(
            self.position,
            Point2::new(0.0, 0.0),
            Point2::new(1280.0 - self.size.x / 2.0, 720.0 - self.size.y / 2.0),
        );
    }

    pub fn draw(&self, ctx: &mut Context) {
        graphics::set_color(ctx, self.color).unwrap();
        graphics::draw(ctx, &self.shape, self.position, 0.0).unwrap();
    }
}

pub struct Officer {
    pub position: Point2,
    pub color: Color,
    pub velocity: Point2,
    pub max_velocity: f32,
    pub size: Point2,
    pub shape: Mesh,
}

impl Officer {
    pub fn build_officer(ctx: &mut Context, pos: Point2) -> Officer {
        Officer {
            position: pos,
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
            size: Point2::new(10.0, 10.0),
            shape: Mesh::new_circle(ctx, DrawMode::Fill, Point2::new(0.0, 0.0), 10.0, 0.2).unwrap(),
        }
    }

    pub fn update(&mut self, targets: &Vec<Demonstrator>) {
        let target = &targets[0];

        // Seek behaviour
        let desired_velocity =
            normalize_vector(sub_vectors(target.position, self.position)) * self.max_velocity;
        let steering = desired_velocity - self.velocity;
        self.velocity = self.velocity + steering;

        // Update position
        self.position = sum_vectors(self.position, self.velocity);
    }

    pub fn draw(&self, ctx: &mut Context) {
        graphics::set_color(ctx, self.color).unwrap();
        graphics::draw(ctx, &self.shape, self.position, 0.0).unwrap();
    }
}
