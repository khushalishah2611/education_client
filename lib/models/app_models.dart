import 'package:flutter/material.dart';

@immutable
class UniversityData {
  const UniversityData({
    required this.name,
    required this.location,
    required this.shortCode,
    required this.color,
    required this.heroImage,
  });

  final String name;
  final String location;
  final String shortCode;
  final Color color;
  final String heroImage;
}

@immutable
class CourseData {
  const CourseData({
    required this.title,
    required this.duration,
    required this.fee,
    required this.image,
  });

  final String title;
  final String duration;
  final String fee;
  final String image;
}

const courseCatalog = [
  CourseData(
    title: 'Bachelor of Computer Science',
    duration: '3 Years',
    fee: '₹60,000 / Year',
    image:
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Master of Business Administration (MBA)',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image:
        'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Information Technology',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image:
        'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Engineering (Automobile)',
    duration: '2 Years',
    fee: '₹60,000 / Year',
    image:
        'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Civil Engineering',
    duration: '4 Years',
    fee: '₹72,000 / Year',
    image:
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
  ),
  CourseData(
    title: 'Bachelor of Media Studies',
    duration: '3 Years',
    fee: '₹55,000 / Year',
    image:
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
  ),
];
