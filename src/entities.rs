use ggez::graphics::{Color, Point2};
use utils::*;

pub struct Demonstrator {
    pub position: Point2,
    pub color: Color,
    pub velocity: Point2,
    pub max_velocity: f32,
    pub size: Point2,
}

impl Demonstrator {
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
}

pub struct Officer {
    pub position: Point2,
    pub color: Color,
    pub velocity: Point2,
    pub max_velocity: f32,
    pub size: Point2,
}

impl Officer {
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
}
